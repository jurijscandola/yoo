import 'package:collection/collection.dart';

import '../../../../core/time/local_date.dart';
import '../entities/activity.dart';
import '../entities/occurrence.dart';

/// Generates new unique ids (UUIDs in the app, predictable ones in tests).
typedef IdGenerator = String Function();

/// An activity on a day, either already stored ([occurrence] set) or only
/// predicted from its recurrence (future days are not stored).
class DayEntry {
  const DayEntry({required this.activity, required this.date, this.occurrence});

  final Activity activity;
  final LocalDate date;

  /// The stored occurrence, or `null` for a prediction.
  final Occurrence? occurrence;

  bool get isPredicted => occurrence == null;
}

/// Result of [OccurrencePlanner.rollover].
class RolloverResult {
  const RolloverResult({required this.changed, required this.processedUntil});

  /// Occurrences to insert or update.
  final List<Occurrence> changed;

  /// The date to remember as processed (today).
  final LocalDate processedUntil;
}

/// Result of [OccurrencePlanner.moveToDay].
class MoveResult {
  const MoveResult({required this.original, required this.moved});

  /// The source occurrence, now missed with resolution "moved".
  final Occurrence original;

  /// The fresh copy on the target day.
  final Occurrence moved;
}

/// Pure rules deciding which occurrences exist on which day.
///
/// Storage strategy: occurrences are stored for past days and today (created
/// by [rollover]); future days are predicted from recurrences, except copies
/// moved there explicitly by the user.
class OccurrencePlanner {
  const OccurrencePlanner({this.maxCatchUpDays = 62});

  /// How far back [rollover] fills days the app was never opened on.
  final int maxCatchUpDays;

  /// Occurrences that must be created on [date]: one per planned activity
  /// that has no occurrence there yet (so moved copies are never duplicated).
  List<Occurrence> missingOn({
    required LocalDate date,
    required Iterable<Activity> activities,
    required Iterable<Occurrence> existingOnDate,
    required IdGenerator newId,
    required DateTime now,
  }) {
    final present = {for (final o in existingOnDate) o.activityId};
    return [
      for (final activity in activities)
        if (activity.isPlannedOn(date) && !present.contains(activity.id))
          Occurrence(
            id: newId(),
            activityId: activity.id,
            date: date,
            originalDate: date,
            updatedAt: now,
          ),
    ];
  }

  /// Brings stored occurrences up to [today]:
  /// 1. creates the occurrences of every day since [lastProcessed] (bounded by
  ///    [maxCatchUpDays]) so that summaries also cover days the app was closed;
  /// 2. marks past open occurrences as missed, waiting for the user's decision;
  /// 3. keeps only the latest unresolved missed occurrence per activity: older
  ///    ones are resolved as "left incomplete" to avoid a flood of questions.
  ///
  /// [existing] must contain the stored occurrences from [lastProcessed]
  /// (or today) onwards, plus any unresolved missed ones.
  RolloverResult rollover({
    required LocalDate today,
    required LocalDate? lastProcessed,
    required List<Activity> activities,
    required List<Occurrence> existing,
    required IdGenerator newId,
    required DateTime now,
  }) {
    final earliest = today.addDays(-maxCatchUpDays);
    var start = lastProcessed ?? today;
    if (start.isBefore(earliest)) start = earliest;
    if (start.isAfter(today)) start = today;

    final all = <String, Occurrence>{for (final o in existing) o.id: o};
    final changedIds = <String>{};
    final byDate = groupBy(existing, (Occurrence o) => o.date);

    // 1. Fill every day in the range.
    for (final day in start.rangeTo(today)) {
      final created = missingOn(
        date: day,
        activities: activities,
        existingOnDate: byDate[day] ?? const [],
        newId: newId,
        now: now,
      );
      for (final o in created) {
        all[o.id] = o;
        changedIds.add(o.id);
      }
    }

    // 2. Past open occurrences become missed.
    for (final o in all.values.toList()) {
      if (o.isOpen && o.date.isBefore(today)) {
        all[o.id] = o.copyWith(
          status: OccurrenceStatus.missed,
          resolution: () => MissedResolution.unresolved,
          updatedAt: now,
        );
        changedIds.add(o.id);
      }
    }

    // 3. One pending question per activity: the most recent missed day.
    final unresolved = all.values.where(
      (o) => o.status == OccurrenceStatus.missed && o.resolution == MissedResolution.unresolved,
    );
    for (final group in groupBy(unresolved, (Occurrence o) => o.activityId).values) {
      group.sort((a, b) => b.date.compareTo(a.date));
      for (final older in group.skip(1)) {
        all[older.id] = older.copyWith(
          resolution: () => MissedResolution.leftIncomplete,
          updatedAt: now,
        );
        changedIds.add(older.id);
      }
    }

    return RolloverResult(changed: [for (final id in changedIds) all[id]!], processedUntil: today);
  }

  /// Whether [activity] already has an occurrence on [target], stored or
  /// predicted from its recurrence. Moving there would create a duplicate.
  bool hasOccurrenceOn({
    required Activity activity,
    required LocalDate target,
    required Iterable<Occurrence> storedOnTarget,
  }) {
    return activity.isPlannedOn(target) ||
        storedOnTarget.any(
          (o) => o.activityId == activity.id && o.status != OccurrenceStatus.skipped,
        );
  }

  /// Moves [source] (missed, or still open today) to [target] with the same
  /// settings and fresh progress. Returns `null` when [target] already has an
  /// occurrence of the activity.
  MoveResult? moveToDay({
    required Activity activity,
    required Occurrence source,
    required LocalDate target,
    required Iterable<Occurrence> storedOnTarget,
    required IdGenerator newId,
    required DateTime now,
  }) {
    if (!target.isAfter(source.date)) return null;
    if (source.isCompleted || source.status == OccurrenceStatus.skipped) return null;
    if (hasOccurrenceOn(activity: activity, target: target, storedOnTarget: storedOnTarget)) {
      return null;
    }
    return MoveResult(
      original: source.copyWith(
        status: OccurrenceStatus.missed,
        resolution: () => MissedResolution.moved,
        updatedAt: now,
      ),
      moved: Occurrence(
        id: newId(),
        activityId: activity.id,
        date: target,
        originalDate: source.originalDate,
        updatedAt: now,
      ),
    );
  }

  /// Everything shown for [date]: stored occurrences, plus (for days after
  /// [today]) predictions for planned activities with no stored occurrence.
  /// Skipped occurrences are omitted. Sorted by activity name.
  List<DayEntry> entriesOn({
    required LocalDate date,
    required LocalDate today,
    required Map<String, Activity> activitiesById,
    required Iterable<Occurrence> storedOnDate,
  }) {
    final entries = <DayEntry>[];
    final present = <String>{};
    for (final o in storedOnDate) {
      present.add(o.activityId);
      final activity = activitiesById[o.activityId];
      if (activity == null || o.status == OccurrenceStatus.skipped) continue;
      entries.add(DayEntry(activity: activity, date: date, occurrence: o));
    }
    // Today is predicted too, in case rollover has not stored it yet.
    if (!date.isBefore(today)) {
      for (final activity in activitiesById.values) {
        if (!present.contains(activity.id) && activity.isPlannedOn(date)) {
          entries.add(DayEntry(activity: activity, date: date));
        }
      }
    }
    entries.sort((a, b) => a.activity.name.toLowerCase().compareTo(b.activity.name.toLowerCase()));
    return entries;
  }
}
