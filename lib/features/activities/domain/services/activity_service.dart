import '../../../../core/database/key_value_store.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/time/local_date.dart';
import '../entities/activity.dart';
import '../entities/activity_draft.dart';
import '../entities/occurrence.dart';
import '../repositories/activity_repository.dart';
import '../repositories/occurrence_repository.dart';
import 'occurrence_planner.dart';

/// Called after every change, with the days whose data changed. The app uses
/// it to refresh the notification schedule and check monthly goals.
typedef ChangeHook = Future<void> Function(Set<LocalDate> changedDays);

/// Use cases on activities and their occurrences.
///
/// Every write goes through here, so the same rules apply whether the action
/// comes from the UI or from a notification handled in background.
class ActivityService {
  ActivityService({
    required this._activities,
    required this._occurrences,
    required this._store,
    required this._clock,
    required this._newId,
    this._onChanged,
    this._planner = const OccurrencePlanner(),
  });

  final ActivityRepository _activities;
  final OccurrenceRepository _occurrences;
  final KeyValueStore _store;
  final Clock _clock;
  final IdGenerator _newId;
  final ChangeHook? _onChanged;
  final OccurrencePlanner _planner;

  LocalDate get _today => _clock.today();

  Future<void> _changed(Set<LocalDate> days) async => _onChanged?.call(days);

  // ---------------------------------------------------------------------------
  // Activities
  // ---------------------------------------------------------------------------

  /// Creates an activity from [draft]. If it is planned today, today's
  /// occurrence is stored right away.
  Future<Activity> create(ActivityDraft draft) async {
    final now = _clock.now();
    final activity = Activity(
      id: _newId(),
      name: draft.name.trim(),
      notificationText: draft.notificationText.trim(),
      borderColorIndex: draft.borderColorIndex,
      recurrence: draft.recurrence,
      timeSlots: draft.timeSlots,
      startDate: draft.startDate,
      partial: draft.partial,
      goalLink: draft.goalLink,
      createdAt: now,
      updatedAt: now,
    );
    await _activities.save(activity);
    await _materializeToday([activity]);
    await _changed({_today});
    return activity;
  }

  /// Replaces the editable fields of [activity] with [draft].
  Future<Activity> update(Activity activity, ActivityDraft draft) async {
    final updated = activity.copyWith(
      name: draft.name.trim(),
      notificationText: draft.notificationText.trim(),
      borderColorIndex: draft.borderColorIndex,
      recurrence: draft.recurrence,
      timeSlots: draft.timeSlots,
      startDate: draft.startDate,
      partial: () => draft.partial,
      goalLink: () => draft.goalLink,
      updatedAt: _clock.now(),
    );
    await _activities.save(updated);
    await _materializeToday([updated]);
    await _changed({_today});
    return updated;
  }

  /// Deletes the whole activity: it is no longer planned and its open
  /// occurrences (today and moved copies) disappear. History is kept.
  Future<void> deleteActivity(String activityId) async {
    final activity = await _activities.getById(activityId);
    if (activity == null) return;
    final now = _clock.now();
    await _activities.save(activity.copyWith(deletedAt: () => now, updatedAt: now));
    final open = (await _occurrences.getFrom(
      _today,
    )).where((o) => o.activityId == activityId && o.isOpen);
    await _occurrences.saveAll([
      for (final o in open) o.copyWith(status: OccurrenceStatus.skipped, updatedAt: now),
    ]);
    await _changed({_today});
  }

  /// Removes the activity from [date] only.
  Future<void> skipDay(String activityId, LocalDate date) async {
    final occurrence = await _ensureOccurrence(activityId, date);
    if (occurrence == null) return;
    await _occurrences.saveAll([
      occurrence.copyWith(status: OccurrenceStatus.skipped, updatedAt: _clock.now()),
    ]);
    await _changed({date});
  }

  // ---------------------------------------------------------------------------
  // Completion
  // ---------------------------------------------------------------------------

  /// Registers one completed time of the activity on [date] (today).
  Future<Occurrence?> markTimeDone(String activityId, LocalDate date) async {
    final activity = await _activities.getById(activityId);
    final occurrence = await _ensureOccurrence(activityId, date);
    if (activity == null || occurrence == null || !occurrence.isOpen) return occurrence;
    final updated = occurrence.markTimeDone(activity, _clock.now());
    await _occurrences.saveAll([updated]);
    await _changed({date});
    return updated;
  }

  /// Sets the completion percentage of a partial activity on [date] (today).
  Future<Occurrence?> setProgress(String activityId, LocalDate date, int percent) async {
    final occurrence = await _ensureOccurrence(activityId, date);
    if (occurrence == null || !occurrence.isOpen) return occurrence;
    final updated = occurrence.withProgress(percent, _clock.now());
    await _occurrences.saveAll([updated]);
    await _changed({date});
    return updated;
  }

  /// Undoes today's completion of an activity (ticked by mistake): it goes
  /// back to Home and its reminders start again. Other days are unchanged.
  /// Returns whether something changed.
  Future<bool> reopen(String activityId, LocalDate date) async {
    if (date != _today) return false;
    final activity = await _activities.getById(activityId);
    final occurrence = await _occurrences.find(activityId, date);
    if (activity == null || occurrence == null || !occurrence.isCompleted) return false;
    await _occurrences.saveAll([occurrence.reopen(activity, _clock.now())]);
    await _changed({date});
    return true;
  }

  /// Marks a past occurrence as done ("I forgot to tick it"). If it had been
  /// moved, the open copy is removed so it is not done twice.
  Future<void> completeRetroactively(String occurrenceId) async {
    final occurrence = await _occurrences.getById(occurrenceId);
    if (occurrence == null || occurrence.isCompleted) return;
    final activity = await _activities.getById(occurrence.activityId);
    if (activity == null) return;
    final now = _clock.now();
    final changes = [occurrence.completeRetroactively(activity, now)];
    final changedDays = {occurrence.date};
    if (occurrence.resolution == MissedResolution.moved) {
      final copies = (await _occurrences.getFrom(occurrence.date.addDays(1))).where(
        (o) =>
            o.activityId == occurrence.activityId &&
            o.originalDate == occurrence.originalDate &&
            o.isOpen,
      );
      for (final copy in copies) {
        changes.add(copy.copyWith(status: OccurrenceStatus.skipped, updatedAt: now));
        changedDays.add(copy.date);
      }
    }
    await _occurrences.saveAll(changes);
    await _changed(changedDays);
  }

  // ---------------------------------------------------------------------------
  // Missed occurrences
  // ---------------------------------------------------------------------------

  /// Accepts that a missed occurrence was not done.
  Future<void> leaveIncomplete(String occurrenceId) async {
    final occurrence = await _occurrences.getById(occurrenceId);
    if (occurrence == null || occurrence.status != OccurrenceStatus.missed) return;
    await _occurrences.saveAll([
      occurrence.copyWith(
        resolution: () => MissedResolution.leftIncomplete,
        updatedAt: _clock.now(),
      ),
    ]);
    await _changed({occurrence.date});
  }

  /// The day a "move to the next day" would target: tomorrow for today's
  /// occurrences, today for missed ones (the past cannot be planned).
  LocalDate moveTargetFor(Occurrence occurrence) {
    final next = occurrence.date.addDays(1);
    return next.isBefore(_today) ? _today : next;
  }

  /// Whether [occurrence] can be moved to [moveTargetFor] without creating a
  /// duplicate there.
  Future<bool> canMoveToNextDay(Occurrence occurrence) async {
    if (occurrence.isCompleted || occurrence.status == OccurrenceStatus.skipped) return false;
    if (occurrence.resolution == MissedResolution.moved) return false;
    final activity = await _activities.getById(occurrence.activityId);
    if (activity == null || activity.isDeleted) return false;
    final target = moveTargetFor(occurrence);
    return !_planner.hasOccurrenceOn(
      activity: activity,
      target: target,
      storedOnTarget: await _occurrences.getBetween(target, target),
    );
  }

  /// Moves [occurrenceId] to the next free day with the same settings.
  /// Returns `false` when the target day already has an occurrence of it.
  Future<bool> moveToNextDay(String occurrenceId) async {
    final source = await _occurrences.getById(occurrenceId);
    if (source == null || source.resolution == MissedResolution.moved) return false;
    final activity = await _activities.getById(source.activityId);
    if (activity == null || activity.isDeleted) return false;
    final target = moveTargetFor(source);
    final result = _planner.moveToDay(
      activity: activity,
      source: source,
      target: target,
      storedOnTarget: await _occurrences.getBetween(target, target),
      newId: _newId,
      now: _clock.now(),
    );
    if (result == null) return false;
    await _occurrences.saveAll([result.original, result.moved]);
    await _changed({source.date, target});
    return true;
  }

  // ---------------------------------------------------------------------------
  // Day rollover
  // ---------------------------------------------------------------------------

  /// Brings stored data up to today (see [OccurrencePlanner.rollover]). Safe to
  /// call often: on start, on resume, at midnight and from background tasks.
  Future<void> rollover() async {
    final today = _today;
    final raw = await _store.read(StoreKeys.lastProcessedDate);
    final lastProcessed = raw == null ? null : LocalDate.parse(raw);
    // Load the whole catch-up window, not just the days since the last run:
    // occurrences may have been stored before the first rollover ever ran.
    final existing = {
      for (final o in await _occurrences.getFrom(today.addDays(-_planner.maxCatchUpDays))) o.id: o,
      for (final o in await _occurrences.getUnresolvedMissed()) o.id: o,
    };
    final result = _planner.rollover(
      today: today,
      lastProcessed: lastProcessed,
      activities: await _activities.getAll(),
      existing: existing.values.toList(),
      newId: _newId,
      now: _clock.now(),
    );
    await _occurrences.saveAll(result.changed);
    await _store.write(StoreKeys.lastProcessedDate, result.processedUntil.toString());
    if (result.changed.isNotEmpty || lastProcessed != today) {
      await _changed({for (final o in result.changed) o.date, today});
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns the stored occurrence of [activityId] on [date], creating it when
  /// the activity is planned there but not stored yet (today / future).
  Future<Occurrence?> _ensureOccurrence(String activityId, LocalDate date) async {
    final stored = await _occurrences.find(activityId, date);
    if (stored != null) return stored;
    final activity = await _activities.getById(activityId);
    if (activity == null || !activity.isPlannedOn(date) || date.isBefore(_today)) return null;
    final created = Occurrence(
      id: _newId(),
      activityId: activityId,
      date: date,
      originalDate: date,
      updatedAt: _clock.now(),
    );
    await _occurrences.saveAll([created]);
    return created;
  }

  Future<void> _materializeToday(List<Activity> activities) async {
    final today = _today;
    final created = _planner.missingOn(
      date: today,
      activities: activities,
      existingOnDate: await _occurrences.getBetween(today, today),
      newId: _newId,
      now: _clock.now(),
    );
    await _occurrences.saveAll(created);
  }
}
