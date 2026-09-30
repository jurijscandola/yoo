import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/time/local_date.dart';
import '../domain/entities/subtask.dart';
import '../domain/repositories/subtask_repository.dart';

/// [SubtaskRepository] backed by the local Drift database.
class DriftSubtaskRepository implements SubtaskRepository {
  DriftSubtaskRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$SubtasksTable, SubtaskRow> _forActivity(String activityId) =>
      _db.select(_db.subtasks)
        ..where((t) => t.activityId.equals(activityId))
        ..orderBy([(t) => OrderingTerm.asc(t.position), (t) => OrderingTerm.asc(t.createdAt)]);

  @override
  Stream<List<Subtask>> watchForActivity(String activityId) =>
      _forActivity(activityId).watch().map((rows) => rows.map(_fromRow).toList());

  @override
  Future<List<Subtask>> getForActivity(String activityId) async =>
      (await _forActivity(activityId).get()).map(_fromRow).toList();

  @override
  Stream<Set<String>> watchChecked(String activityId, LocalDate date) {
    final q = _db.select(_db.subtaskChecks).join([
      innerJoin(_db.subtasks, _db.subtasks.id.equalsExp(_db.subtaskChecks.subtaskId)),
    ])..where(_db.subtasks.activityId.equals(activityId) & _db.subtaskChecks.date.equals('$date'));
    return q.watch().map(
      (rows) => {for (final r in rows) r.readTable(_db.subtaskChecks).subtaskId},
    );
  }

  @override
  Future<void> save(Subtask subtask) => _db
      .into(_db.subtasks)
      .insertOnConflictUpdate(
        SubtasksCompanion.insert(
          id: subtask.id,
          activityId: subtask.activityId,
          title: subtask.title,
          position: subtask.position,
          createdAt: subtask.createdAt,
          updatedAt: subtask.updatedAt,
        ),
      );

  @override
  Future<void> delete(String subtaskId) => _db.transaction(() async {
    await (_db.delete(_db.subtaskChecks)..where((t) => t.subtaskId.equals(subtaskId))).go();
    await (_db.delete(_db.subtasks)..where((t) => t.id.equals(subtaskId))).go();
  });

  @override
  Future<void> setChecked(
    String subtaskId,
    LocalDate date, {
    required bool checked,
    DateTime? at,
  }) async {
    if (checked) {
      await _db
          .into(_db.subtaskChecks)
          .insertOnConflictUpdate(
            SubtaskChecksCompanion.insert(
              subtaskId: subtaskId,
              date: '$date',
              checkedAt: at ?? DateTime.now(),
            ),
          );
    } else {
      await (_db.delete(
        _db.subtaskChecks,
      )..where((t) => t.subtaskId.equals(subtaskId) & t.date.equals('$date'))).go();
    }
  }
}

Subtask _fromRow(SubtaskRow row) => Subtask(
  id: row.id,
  activityId: row.activityId,
  title: row.title,
  position: row.position,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
);
