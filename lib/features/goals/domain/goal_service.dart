import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
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

  /// Percent, 0–100.
  final double progress;
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
  Future<MonthlyGoal> create({required int year, required int month, required String title}) async {
    final now = _clock.now();
    final goal = MonthlyGoal(
      id: _newId(),
      year: year,
      month: month,
      title: title.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _goals.save(goal);
    return goal;
  }

  /// Renames a goal.
  Future<void> rename(MonthlyGoal goal, String title) =>
      _goals.save(goal.copyWith(title: title.trim(), updatedAt: _clock.now()));

  /// Soft-deletes a goal. Linked activities keep their link, which simply no
  /// longer matches a visible goal.
  Future<void> delete(MonthlyGoal goal) {
    final now = _clock.now();
    return _goals.save(goal.copyWith(deletedAt: () => now, updatedAt: now));
  }

  /// Progress of every goal of [year]/[month].
  Future<List<GoalProgress>> progressOfMonth(int year, int month) async {
    final goals = await _goals.getMonth(year, month);
    if (goals.isEmpty) return const [];
    final activities = {for (final a in await _activities.getAll(includeDeleted: true)) a.id: a};
    final first = LocalDate(year, month, 1);
    final occurrences = await _occurrences.getBetween(first, first.lastOfMonth);
    return [
      for (final g in goals)
        GoalProgress(
          g,
          _calculator.progressOf(goal: g, activitiesById: activities, occurrences: occurrences),
        ),
    ];
  }

  /// Sends the one-shot notification for goals of [year]/[month] that just
  /// reached 100%, and remembers it.
  Future<void> checkCompletions(int year, int month) async {
    for (final p in await progressOfMonth(year, month)) {
      if (!_calculator.shouldNotifyCompletion(p.goal, p.progress)) continue;
      final now = _clock.now();
      await _goals.save(p.goal.copyWith(completionNotifiedAt: () => now, updatedAt: now));
      await _notifier?.notifyGoalReached(p.goal);
    }
  }
}
