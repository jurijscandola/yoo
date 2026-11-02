import '../../../core/time/local_date.dart';

/// What the user decided about a goal (`null` while it is open).
enum GoalOutcome {
  /// Marked as completed by hand, whatever its progress.
  completed,

  /// Continued, from zero, in a later month (see [MonthlyGoal.movedFromId]).
  moved,

  /// Accepted as not reached.
  leftIncomplete,
}

/// A goal for a given month, fed by the activities linked to it.
class MonthlyGoal {
  const MonthlyGoal({
    required this.id,
    required this.year,
    required this.month,
    required this.title,
    required this.target,
    required this.createdAt,
    required this.updatedAt,
    this.completionNotifiedAt,
    this.outcome,
    this.frozenProgress,
    this.resolvedAt,
    this.movedFromId,
    this.deletedAt,
  });

  final String id;
  final int year;
  final int month;
  final String title;

  /// Amount to reach (e.g. 4 books, or 1 for a single event). Completing a
  /// linked activity adds or removes its impact from the progress.
  final int target;

  /// When the "goal reached" notification was sent (sent only once).
  final DateTime? completionNotifiedAt;

  /// The user's decision; `null` while the goal is open.
  final GoalOutcome? outcome;

  /// Progress when [outcome] was decided. It is kept as it was, so relinking
  /// activities afterwards (e.g. to the moved copy) does not rewrite it.
  final double? frozenProgress;

  final DateTime? resolvedAt;

  /// Id of the goal of an earlier month this one continues.
  final String? movedFromId;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Soft-delete marker.
  final DateTime? deletedAt;

  /// Whether [date] falls in this goal's month.
  bool contains(LocalDate date) => date.year == year && date.month == month;

  bool get isResolved => outcome != null;

  /// The month a goal of [year]/[month] moves to on [today]: the following
  /// one, or the current month when that one is already over.
  static (int, int) moveTarget(int year, int month, LocalDate today) {
    final next = month == 12 ? (year + 1, 1) : (year, month + 1);
    final overAt = next.$1 < today.year || (next.$1 == today.year && next.$2 < today.month);
    return overAt ? (today.year, today.month) : next;
  }

  /// Month of the copy this goal was moved to, if it was.
  (int, int)? get movedTo {
    final at = resolvedAt;
    if (outcome != GoalOutcome.moved || at == null) return null;
    return moveTarget(year, month, LocalDate(at.year, at.month, at.day));
  }

  /// Whether this goal's month ended before [today]'s.
  bool isPastAt(LocalDate today) =>
      year < today.year || (year == today.year && month < today.month);

  /// A copy with the user's decision and the progress it was taken at.
  MonthlyGoal resolved(GoalOutcome outcome, double progress, DateTime now) =>
      _with(outcome: outcome, frozenProgress: progress, resolvedAt: now, updatedAt: now);

  /// A copy back to open. Its progress is computed live again, unless
  /// [frozenProgress] is kept (e.g. its activities now feed another goal).
  MonthlyGoal reopened(DateTime now, {double? frozenProgress}) =>
      _with(frozenProgress: frozenProgress, updatedAt: now);

  /// A copy whose progress stays at [progress], with the same decision.
  MonthlyGoal frozenAt(double progress, DateTime now) =>
      _with(outcome: outcome, frozenProgress: progress, resolvedAt: resolvedAt, updatedAt: now);

  MonthlyGoal _with({
    GoalOutcome? outcome,
    double? frozenProgress,
    DateTime? resolvedAt,
    required DateTime updatedAt,
  }) => MonthlyGoal(
    id: id,
    year: year,
    month: month,
    title: title,
    target: target,
    completionNotifiedAt: completionNotifiedAt,
    outcome: outcome,
    frozenProgress: frozenProgress,
    resolvedAt: resolvedAt,
    movedFromId: movedFromId,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );

  MonthlyGoal copyWith({
    String? title,
    int? target,
    DateTime? Function()? completionNotifiedAt,
    DateTime? updatedAt,
    DateTime? Function()? deletedAt,
  }) {
    return MonthlyGoal(
      id: id,
      year: year,
      month: month,
      title: title ?? this.title,
      target: target ?? this.target,
      completionNotifiedAt: completionNotifiedAt != null
          ? completionNotifiedAt()
          : this.completionNotifiedAt,
      outcome: outcome,
      frozenProgress: frozenProgress,
      resolvedAt: resolvedAt,
      movedFromId: movedFromId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }
}
