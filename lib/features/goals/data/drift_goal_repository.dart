import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/goal_repository.dart';
import '../domain/monthly_goal.dart';

/// [GoalRepository] backed by the local Drift database.
class DriftGoalRepository implements GoalRepository {
  DriftGoalRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$GoalsTable, GoalRow> _month(int year, int month) =>
      _db.select(_db.goals)
        ..where((t) => t.year.equals(year) & t.month.equals(month) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);

  @override
  Stream<List<MonthlyGoal>> watchMonth(int year, int month) =>
      _month(year, month).watch().map((rows) => rows.map(goalFromRow).toList());

  @override
  Future<List<MonthlyGoal>> getMonth(int year, int month) async =>
      (await _month(year, month).get()).map(goalFromRow).toList();

  @override
  Stream<List<MonthlyGoal>> watchAll() {
    final q = _db.select(_db.goals)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.year), (t) => OrderingTerm.desc(t.month)]);
    return q.watch().map((rows) => rows.map(goalFromRow).toList());
  }

  @override
  Future<MonthlyGoal?> getById(String id) async {
    final row = await (_db.select(_db.goals)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : goalFromRow(row);
  }

  @override
  Future<void> save(MonthlyGoal goal) => _db.into(_db.goals).insertOnConflictUpdate(
    GoalsCompanion.insert(
      id: goal.id,
      year: goal.year,
      month: goal.month,
      title: goal.title,
      completionNotifiedAt: Value(goal.completionNotifiedAt),
      createdAt: goal.createdAt,
      updatedAt: goal.updatedAt,
      deletedAt: Value(goal.deletedAt),
    ),
  );
}

/// Maps a database row to the domain entity.
MonthlyGoal goalFromRow(GoalRow row) => MonthlyGoal(
  id: row.id,
  year: row.year,
  month: row.month,
  title: row.title,
  completionNotifiedAt: row.completionNotifiedAt,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
  deletedAt: row.deletedAt,
);
