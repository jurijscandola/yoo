import '../../../../core/time/local_date.dart';
import 'activity.dart';

/// Lifecycle of an occurrence.
enum OccurrenceStatus {
  /// Today or in the future, not completed yet.
  pending,

  /// Fully completed.
  completed,

  /// The day ended without full completion (see [MissedResolution]).
  missed,

  /// Removed by the user for that day only: hidden and not counted anywhere.
  skipped,
}

/// What the user decided about a missed occurrence.
enum MissedResolution {
  /// Waiting for the user's decision.
  unresolved,

  /// The user accepted that it was not done.
  leftIncomplete,

  /// A copy was planned on a later day.
  moved,
}

/// One instance of an activity on a given day.
///
/// There is at most one occurrence per activity per day; an activity done
/// several times a day tracks progress with [completedCount].
class Occurrence {
  const Occurrence({
    required this.id,
    required this.activityId,
    required this.date,
    required this.originalDate,
    required this.updatedAt,
    this.status = OccurrenceStatus.pending,
    this.completedCount = 0,
    this.progress = 0,
    this.resolution,
    this.completedAt,
    this.retroactive = false,
  });

  final String id;
  final String activityId;

  /// Day the occurrence is shown on.
  final LocalDate date;

  /// Day it was originally planned on (differs from [date] when moved).
  final LocalDate originalDate;

  final OccurrenceStatus status;

  /// How many of the daily times are done (counter activities).
  final int completedCount;

  /// Completion percentage 0–100 (partial activities).
  final int progress;

  /// Decision about a missed occurrence; `null` unless [status] is missed.
  final MissedResolution? resolution;

  final DateTime? completedAt;

  /// Whether it was marked completed after its day ended.
  final bool retroactive;

  final DateTime updatedAt;

  /// Whether this occurrence was moved here from an earlier day.
  bool get wasMoved => date != originalDate;

  bool get isCompleted => status == OccurrenceStatus.completed;

  /// Still actionable (shown on Home and reminded).
  bool get isOpen => status == OccurrenceStatus.pending;

  /// Completion degree 0.0–1.0 for [activity]: the percentage for partial
  /// activities, the done/total ratio for counters.
  double completionFor(Activity activity) {
    if (status == OccurrenceStatus.completed) return 1;
    if (status == OccurrenceStatus.skipped) return 0;
    if (activity.isPartial) return (progress / 100).clamp(0, 1).toDouble();
    return (completedCount / activity.timesPerDay).clamp(0, 1).toDouble();
  }

  /// Registers one more completed time. Completes the occurrence when all the
  /// daily times are done.
  Occurrence markTimeDone(Activity activity, DateTime now) {
    final count = (completedCount + 1).clamp(0, activity.timesPerDay);
    final done = count >= activity.timesPerDay;
    return copyWith(
      completedCount: count,
      progress: done ? 100 : progress,
      status: done ? OccurrenceStatus.completed : status,
      completedAt: done ? () => now : null,
      updatedAt: now,
    );
  }

  /// Sets the completion percentage of a partial activity (100 completes it).
  Occurrence withProgress(int percent, DateTime now) {
    final value = percent.clamp(0, 100);
    final done = value >= 100;
    return copyWith(
      progress: value,
      status: done ? OccurrenceStatus.completed : OccurrenceStatus.pending,
      completedAt: () => done ? now : null,
      updatedAt: now,
    );
  }

  /// Undoes the completion ("I ticked it by mistake"): counters lose their
  /// last time (3/3 → 2/3), partial activities go back to 0%.
  Occurrence reopen(Activity activity, DateTime now) => copyWith(
    status: OccurrenceStatus.pending,
    completedCount: activity.isPartial ? completedCount : (activity.timesPerDay - 1).clamp(0, 99),
    progress: 0,
    completedAt: () => null,
    retroactive: false,
    updatedAt: now,
  );

  /// Marks a missed occurrence as done after its day ended.
  Occurrence completeRetroactively(Activity activity, DateTime now) => copyWith(
    status: OccurrenceStatus.completed,
    completedCount: activity.timesPerDay,
    progress: 100,
    resolution: () => null,
    completedAt: () => now,
    retroactive: true,
    updatedAt: now,
  );

  Occurrence copyWith({
    LocalDate? date,
    OccurrenceStatus? status,
    int? completedCount,
    int? progress,
    MissedResolution? Function()? resolution,
    DateTime? Function()? completedAt,
    bool? retroactive,
    DateTime? updatedAt,
  }) {
    return Occurrence(
      id: id,
      activityId: activityId,
      date: date ?? this.date,
      originalDate: originalDate,
      status: status ?? this.status,
      completedCount: completedCount ?? this.completedCount,
      progress: progress ?? this.progress,
      resolution: resolution != null ? resolution() : this.resolution,
      completedAt: completedAt != null ? completedAt() : this.completedAt,
      retroactive: retroactive ?? this.retroactive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Occurrence($activityId @ $date, ${status.name}, $completedCount, $progress%)';
}
