import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../activities/domain/entities/activity.dart';
import '../../activities/domain/repositories/activity_repository.dart';
import '../../activities/domain/repositories/occurrence_repository.dart';
import '../../activities/domain/services/occurrence_planner.dart';
import 'goal_progress_calculator.dart';
import 'goal_repository.dart';
import 'monthly_goal.dart';

/// Sends the "goal reached" notification (implemented by the reminders layer).
abstract interface class GoalCompletionNotifier {
  Future<void> notifyGoalReached(MonthlyGoal goal);
}

/// A goal with its computed progress.
class GoalProgress {
  const GoalProgress(this.goal, this.progress);

  final MonthlyGoal goal;

  /// Amount reached, 0 to the goal's target (as it was when the user decided
  /// about the goal, for resolved goals).
  final double progress;

  /// Whole units reached (partial shares only count once complete).
  int get reached => progress.floor();

  /// Share of the target reached, 0–1 (1 when marked as completed by hand).
  double get fraction {
    if (goal.outcome == GoalOutcome.completed) return 1;
    return goal.target == 0 ? 0 : (progress / goal.target).clamp(0, 1);
  }

  /// Reached by its activities, or marked as completed by hand.
  bool get isReached => goal.outcome == GoalOutcome.completed || progress >= goal.target;

  /// Its month is over, it was not reached and the user has not decided yet
  /// what to do with it.
  bool needsDecisionAt(LocalDate today) => goal.isPastAt(today) && !goal.isResolved && !isReached;
}

/// Use cases around monthly goals.
class GoalService {
  GoalService({
    required this._goals,
    required this._activities,
    required this._occurrences,
    required this._clock,
    required this._newId,
    this._notifier,
    this._calculator = const GoalProgressCalculator(),
  });

  final GoalRepository _goals;
  final ActivityRepository _activities;
  final OccurrenceRepository _occurrences;
  final Clock _clock;
  final IdGenerator _newId;
  final GoalCompletionNotifier? _notifier;
  final GoalProgressCalculator _calculator;

  /// Creates a goal for [year]/[month].
  Future<MonthlyGoal> create({
    required int year,
    required int month,
    required String title,
    int target = 1,
  }) async {
    final now = _clock.now();
    final goal = MonthlyGoal(
      id: _newId(),
      year: year,
      month: month,
      title: title.trim(),
      target: target,
      createdAt: now,
      updatedAt: now,
    );
    await _goals.save(goal);
    return goal;
  }

  /// Renames a goal and/or changes its target. Raising the target of a
  /// reached goal allows a new "goal reached" notification.
  Future<void> update(MonthlyGoal goal, {required String title, required int target}) =>
      _goals.save(
        goal.copyWith(
          title: title.trim(),
          target: target,
          completionNotifiedAt: target > goal.target ? () => null : null,
          updatedAt: _clock.now(),
        ),
      );

  /// Soft-deletes a goal. Linked activities keep their link, which simply no
  /// longer matches a visible goal.
  Future<void> delete(MonthlyGoal goal) {
    final now = _clock.now();
    return _goals.save(goal.copyWith(deletedAt: () => now, updatedAt: now));
  }

  /// Progress of every goal of [year]/[month].
  Future<List<GoalProgress>> progressOfMonth(int year, int month) async =>
      _withProgress(await _goals.getMonth(year, month));

  /// Live progress from the linked activities, or the one frozen when the
  /// user decided about the goal.
  Future<List<GoalProgress>> _withProgress(List<MonthlyGoal> goals) async {
    if (goals.isEmpty) return const [];
    final activities = {for (final a in await _activities.getAll(includeDeleted: true)) a.id: a};
    final byMonth = <(int, int), List<MonthlyGoal>>{};
    for (final g in goals) {
      byMonth.putIfAbsent((g.year, g.month), () => []).add(g);
    }
    final progress = <String, double>{};
    for (final MapEntry(key: (year, month), value: monthGoals) in byMonth.entries) {
      final first = LocalDate(year, month, 1);
      final occurrences = await _occurrences.getBetween(first, first.lastOfMonth);
      for (final g in monthGoals) {
        progress[g.id] =
            g.frozenProgress ??
            _calculator.progressOf(goal: g, activitiesById: activities, occurrences: occurrences);
      }
    }
    return [for (final g in goals) GoalProgress(g, progress[g.id]!)];
  }

  /// Goals of months already over that were not reached and still wait for
  /// a decision (see [GoalProgress.needsDecisionAt]).
  Future<List<GoalProgress>> toDecide() async {
    final today = _clock.today();
    final open = (await _goals.getAll()).where((g) => g.isPastAt(today) && !g.isResolved);
    return [
      for (final p in await _withProgress(open.toList()))
        if (p.needsDecisionAt(today)) p,
    ];
  }

  Future<double> _liveProgress(MonthlyGoal goal) async =>
      (await _withProgress([goal.reopened(goal.updatedAt)])).single.progress;

  // ---------------------------------------------------------------------------
  // Decisions (monthly summary)
  // ---------------------------------------------------------------------------

  /// Progress of [goal] as it is now: frozen once its activities moved on or
  /// a decision was taken, live otherwise.
  Future<double> _currentProgress(MonthlyGoal goal) async =>
      goal.frozenProgress ?? await _liveProgress(goal);

  /// Marks [goal] as completed by hand, whatever its progress (e.g. a goal no
  /// activity feeds). No notification: the user did it.
  Future<void> markCompleted(MonthlyGoal goal) async {
    if (goal.outcome == GoalOutcome.moved) return;
    final now = _clock.now();
    await _goals.save(
      goal
          .resolved(GoalOutcome.completed, await _currentProgress(goal), now)
          .copyWith(completionNotifiedAt: () => goal.completionNotifiedAt ?? now),
    );
  }

  /// Accepts that [goal] was not reached.
  Future<void> leaveIncomplete(MonthlyGoal goal) async {
    if (goal.isResolved) return;
    final now = _clock.now();
    await _goals.save(goal.resolved(GoalOutcome.leftIncomplete, await _currentProgress(goal), now));
  }

  /// Undoes "completed" or "left incomplete": the goal is open again. Goals
  /// of months already over keep the progress they had (their activities may
  /// feed another goal by now); the others are computed live again. Moved
  /// goals stay moved.
  Future<void> reopen(MonthlyGoal goal) async {
    if (!goal.isResolved || goal.outcome == GoalOutcome.moved) return;
    final keep = goal.isPastAt(_clock.today()) ? goal.frozenProgress : null;
    final open = goal.reopened(_clock.now(), frozenProgress: keep);
    final reached = (keep ?? await _liveProgress(open)) >= goal.target;
    // Marked by hand, it never notified: let a real completion do it.
    await _goals.save(open.copyWith(completionNotifiedAt: reached ? null : () => null));
  }

  /// The month a "move to the next month" targets: the following one, or the
  /// current month for goals of months already over.
  (int, int) moveTargetFor(MonthlyGoal goal) =>
      MonthlyGoal.moveTarget(goal.year, goal.month, _clock.today());

  /// Continues [goal] in [moveTargetFor], from zero: a copy with the same
  /// title and target is created there, the activities linked to [goal] now
  /// feed the copy, and [goal] keeps the progress it had, marked as moved.
  /// Returns the copy, or `null` when [goal] was already decided.
  Future<MonthlyGoal?> moveToNextMonth(MonthlyGoal goal) async {
    if (goal.isResolved) return null;
    final now = _clock.now();
    final (year, month) = moveTargetFor(goal);
    final copy = MonthlyGoal(
      id: _newId(),
      year: year,
      month: month,
      title: goal.title,
      target: goal.target,
      movedFromId: goal.id,
      createdAt: now,
      updatedAt: now,
    );
    await _goals.save(goal.resolved(GoalOutcome.moved, await _currentProgress(goal), now));
    await _goals.save(copy);
    await _relink(goal.id, copy.id, now);
    return copy;
  }

  /// The target a copy of [goal] gets in [year]/[month]: a goal of one per day
  /// of its month (e.g. 31 in October) gets the days of the new month (30 in
  /// November); any other amount stays.
  static int adaptedTarget(MonthlyGoal goal, int year, int month) {
    final sourceDays = LocalDate(goal.year, goal.month, 1).daysInMonth;
    return goal.target == sourceDays ? LocalDate(year, month, 1).daysInMonth : goal.target;
  }

  /// Adds a copy of [goal], from another month, to the current one, with
  /// [title] and [target] (see [adaptedTarget]). Unlike a move, [goal] stays
  /// as it is (open or decided) and keeps the progress it had; the activities
  /// linked to it now feed the copy. Returns `null` for goals of this month.
  Future<MonthlyGoal?> addToCurrentMonth(
    MonthlyGoal goal, {
    required String title,
    required int target,
  }) async {
    final today = _clock.today();
    if (goal.year == today.year && goal.month == today.month) return null;
    final now = _clock.now();
    if (goal.frozenProgress == null) {
      await _goals.save(goal.frozenAt(await _liveProgress(goal), now));
    }
    final copy = MonthlyGoal(
      id: _newId(),
      year: today.year,
      month: today.month,
      title: title.trim(),
      target: target,
      createdAt: now,
      updatedAt: now,
    );
    await _goals.save(copy);
    await _relink(goal.id, copy.id, now);
    return copy;
  }

  /// The activities linked to goal [fromId] now feed goal [toId].
  Future<void> _relink(String fromId, String toId, DateTime now) async {
    for (final activity in await _activities.getAll()) {
      final link = activity.goalLink;
      if (link == null || link.goalId != fromId) continue;
      await _activities.save(
        activity.copyWith(
          goalLink: () => GoalLink(goalId: toId, impact: link.impact, type: link.type),
          updatedAt: now,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------

  /// Sends the one-shot notification for goals of [year]/[month] that just
  /// reached their target, and remembers it.
  Future<void> checkCompletions(int year, int month) async {
    for (final p in await progressOfMonth(year, month)) {
      if (p.goal.isResolved) continue;
      if (!_calculator.shouldNotifyCompletion(p.goal, p.progress)) continue;
      final now = _clock.now();
      await _goals.save(p.goal.copyWith(completionNotifiedAt: () => now, updatedAt: now));
      await _notifier?.notifyGoalReached(p.goal);
    }
  }
}
