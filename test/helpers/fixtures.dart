import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/core/time/local_time.dart';
import 'package:yoo/features/activities/domain/entities/activity.dart';
import 'package:yoo/features/activities/domain/entities/occurrence.dart';
import 'package:yoo/features/activities/domain/entities/recurrence.dart';

/// Reference instant used by domain tests.
final testNow = DateTime(2026, 9, 29, 7);

/// Builds an [Activity] with sensible defaults for tests.
Activity activity(
  String id, {
  Recurrence recurrence = const DailyRecurrence(),
  List<TimeSlot>? slots,
  LocalDate? start,
  PartialConfig? partial,
  GoalLink? goalLink,
  DateTime? deletedAt,
}) {
  return Activity(
    id: id,
    name: 'Activity $id',
    notificationText: 'Do $id',
    borderColorIndex: 0,
    recurrence: recurrence,
    timeSlots: slots ?? const [TimeSlot.at(LocalTime(9, 0))],
    startDate: start ?? LocalDate(2026, 1, 1),
    partial: partial,
    goalLink: goalLink,
    createdAt: testNow,
    updatedAt: testNow,
    deletedAt: deletedAt,
  );
}

/// Builds an [Occurrence] with sensible defaults for tests.
Occurrence occurrence(
  String id,
  String activityId,
  LocalDate date, {
  OccurrenceStatus status = OccurrenceStatus.pending,
  int completedCount = 0,
  int progress = 0,
  MissedResolution? resolution,
  LocalDate? originalDate,
}) {
  return Occurrence(
    id: id,
    activityId: activityId,
    date: date,
    originalDate: originalDate ?? date,
    status: status,
    completedCount: completedCount,
    progress: progress,
    resolution: resolution,
    updatedAt: testNow,
  );
}

/// Sequential ids: id-1, id-2, …
String Function() sequentialIds([String prefix = 'id']) {
  var n = 0;
  return () => '$prefix-${++n}';
}
