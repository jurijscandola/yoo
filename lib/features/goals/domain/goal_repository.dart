import 'monthly_goal.dart';

/// Access to monthly goals.
abstract interface class GoalRepository {
  /// Emits the non-deleted goals of [year]/[month] on change.
  Stream<List<MonthlyGoal>> watchMonth(int year, int month);

  /// Returns the non-deleted goals of [year]/[month].
  Future<List<MonthlyGoal>> getMonth(int year, int month);

  /// Emits every non-deleted goal (used by the activity form picker).
  Stream<List<MonthlyGoal>> watchAll();

  /// Returns the goal with [id], deleted or not.
  Future<MonthlyGoal?> getById(String id);

  /// Inserts or replaces [goal].
  Future<void> save(MonthlyGoal goal);
}
