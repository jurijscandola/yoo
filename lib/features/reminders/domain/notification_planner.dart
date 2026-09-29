import 'package:collection/collection.dart';

import '../../../core/time/local_date.dart';
import '../../../core/time/local_time.dart';
import '../../../core/utils/stable_hash.dart';
import '../../activities/domain/entities/activity.dart';
import '../../activities/domain/entities/occurrence.dart';

/// Kind of a planned reminder.
enum ReminderKind {
  /// One of the daily times of the activity.
  slot,

  /// Follow-up for a partial activity still below 100%.
  followUp,
}

/// A notification to schedule, expressed in wall-clock terms. The platform
/// layer converts [date] + [time] to an instant in the current time zone.
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.activityId,
    required this.date,
    required this.time,
    required this.kind,
    required this.index,
    required this.title,
    required this.body,
    required this.isPartial,
  });

  /// Stable notification id: the same reminder always gets the same id, so
  /// rescheduling replaces instead of duplicating.
  final int id;

  final String activityId;
  final LocalDate date;
  final LocalTime time;
  final ReminderKind kind;

  /// Slot index or follow-up number.
  final int index;

  final String title;
  final String body;

  /// Whether the notification asks for a percentage instead of "done".
  final bool isPartial;

  /// Local date-time of the reminder.
  DateTime get localDateTime => DateTime(date.year, date.month, date.day, time.hour, time.minute);

  /// Payload carried by the notification to identify its occurrence.
  String get payload => ReminderPayload(activityId: activityId, date: date).encode();

  @override
  String toString() => 'PlannedReminder($title @ $date $time, ${kind.name}#$index)';
}

/// Data embedded in a notification to find its occurrence back.
class ReminderPayload {
  const ReminderPayload({required this.activityId, required this.date});

  final String activityId;
  final LocalDate date;

  String encode() => 'occ|$activityId|$date';

  /// Returns `null` for payloads that are not reminders.
  static ReminderPayload? tryDecode(String? raw) {
    final parts = raw?.split('|');
    if (parts == null || parts.length != 3 || parts[0] != 'occ') return null;
    return ReminderPayload(activityId: parts[1], date: LocalDate.parse(parts[2]));
  }
}

/// Decides which reminders must be scheduled, as a pure function of the
/// activities, their stored occurrences and the current time.
///
/// Only the next [maxCount] reminders within [horizonDays] are returned: iOS
/// keeps at most 64 pending notifications, so the schedule is a rolling window
/// refreshed on app start, after every action and periodically in background.
class NotificationPlanner {
  const NotificationPlanner({this.horizonDays = 7, this.maxCount = 48});

  final int horizonDays;
  final int maxCount;

  /// Reminders due after [now], earliest first.
  ///
  /// [stored] must contain stored occurrences from today onwards; days without
  /// a stored occurrence fall back to the recurrence.
  List<PlannedReminder> plan({
    required DateTime now,
    required Iterable<Activity> activities,
    required Iterable<Occurrence> stored,
  }) {
    final today = LocalDate.fromDateTime(now);
    final storedByDay = groupBy(stored, (Occurrence o) => o.date);
    final result = <PlannedReminder>[];

    for (var offset = 0; offset < horizonDays; offset++) {
      final day = today.addDays(offset);
      final storedToday = {
        for (final o in storedByDay[day] ?? const <Occurrence>[]) o.activityId: o,
      };
      for (final activity in activities) {
        if (activity.isDeleted) continue;
        final occurrence = storedToday[activity.id];
        if (occurrence == null && !activity.isPlannedOn(day)) continue;
        if (occurrence != null && !occurrence.isOpen) continue;
        result.addAll(_remindersFor(activity, day, occurrence));
      }
    }

    return result
        .where((r) => r.localDateTime.isAfter(now))
        .sortedBy((r) => r.localDateTime)
        .take(maxCount)
        .toList();
  }

  List<PlannedReminder> _remindersFor(Activity activity, LocalDate day, Occurrence? occurrence) {
    final reminders = <PlannedReminder>[];
    final done = occurrence?.completedCount ?? 0;
    LocalTime? lastSlot;

    for (var i = 0; i < activity.timeSlots.length; i++) {
      final time = slotTime(activity, day, i);
      if (lastSlot == null || time.isAfter(lastSlot)) lastSlot = time;
      // Counter activities: times already done need no reminder.
      if (!activity.isPartial && i < done) continue;
      reminders.add(_reminder(activity, day, time, ReminderKind.slot, i));
    }

    final partial = activity.partial;
    if (partial != null && lastSlot != null && partial.reminderCount > 0) {
      for (final (k, time) in followUpTimes(lastSlot, partial).indexed) {
        reminders.add(_reminder(activity, day, time, ReminderKind.followUp, k));
      }
    }
    return reminders;
  }

  PlannedReminder _reminder(
    Activity a,
    LocalDate day,
    LocalTime time,
    ReminderKind kind,
    int index,
  ) {
    return PlannedReminder(
      id: reminderId(a.id, day, kind, index),
      activityId: a.id,
      date: day,
      time: time,
      kind: kind,
      index: index,
      title: a.name,
      body: a.notificationText,
      isPartial: a.isPartial,
    );
  }

  /// Stable id of a reminder.
  static int reminderId(String activityId, LocalDate day, ReminderKind kind, int index) =>
      stableHash('$activityId|$day|${kind.name}|$index');

  /// The time of slot [index] of [activity] on [day]: a random minute inside
  /// the slot, derived from a seed so it never changes when rescheduling.
  static LocalTime slotTime(Activity activity, LocalDate day, int index) {
    final slot = activity.timeSlots[index];
    final span = slot.to.inMinutes - slot.from.inMinutes;
    if (span <= 0) return slot.from;
    final offset = stableHash('${activity.id}|$day|$index') % (span + 1);
    return LocalTime.fromMinutes(slot.from.inMinutes + offset);
  }

  /// Follow-up times of a partial activity: [PartialConfig.reminderCount]
  /// times spread evenly after [lastSlot], the last one at [PartialConfig.until].
  static List<LocalTime> followUpTimes(LocalTime lastSlot, PartialConfig partial) {
    final span = partial.until.inMinutes - lastSlot.inMinutes;
    if (span <= 0 || partial.reminderCount <= 0) return const [];
    final count = partial.reminderCount;
    // A set drops duplicates when there are more reminders than minutes.
    final times = <LocalTime>{
      for (var k = 1; k <= count; k++)
        LocalTime.fromMinutes(lastSlot.inMinutes + (span * k) ~/ count),
    };
    return times.toList();
  }
}
