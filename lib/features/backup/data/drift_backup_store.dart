import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/backup_file.dart';
import '../domain/backup_service.dart';

/// Reads and merges the user's tables for backups, as Drift's JSON rows.
///
/// Merging never deletes anything: missing rows are added, and a row that
/// exists on both sides is replaced only when the backup's copy is newer
/// (`updatedAt`). Occurrences are matched by activity and day, so a day never
/// ends up with two of them. It all happens in one transaction.
class DriftBackupStore implements BackupStore {
  DriftBackupStore(this._db);

  final AppDatabase _db;

  @override
  int get schemaVersion => _db.schemaVersion;

  @override
  Future<Map<String, List<Map<String, Object?>>>> exportTables() async => {
    'activities': [for (final r in await _db.select(_db.activities).get()) r.toJson()],
    'occurrences': [for (final r in await _db.select(_db.occurrences).get()) r.toJson()],
    'goals': [for (final r in await _db.select(_db.goals).get()) r.toJson()],
    'subtasks': [for (final r in await _db.select(_db.subtasks).get()) r.toJson()],
    'subtaskChecks': [for (final r in await _db.select(_db.subtaskChecks).get()) r.toJson()],
  };

  @override
  Future<BackupImportResult> importTables(BackupFile backup) => _db.transaction(() async {
    var added = 0;
    var updated = 0;
    void count((int, int) result) {
      added += result.$1;
      updated += result.$2;
    }

    count(
      await _mergeById(
        table: _db.activities,
        rows: backup.rowsOf('activities').map(ActivityRow.fromJson),
        local: {for (final r in await _db.select(_db.activities).get()) r.id: r.updatedAt},
        key: (r) => (r.id, r.updatedAt),
      ),
    );
    count(
      await _mergeById(
        table: _db.goals,
        rows: backup.rowsOf('goals').map(GoalRow.fromJson),
        local: {for (final r in await _db.select(_db.goals).get()) r.id: r.updatedAt},
        key: (r) => (r.id, r.updatedAt),
      ),
    );
    count(
      await _mergeById(
        table: _db.subtasks,
        rows: backup.rowsOf('subtasks').map(SubtaskRow.fromJson),
        local: {for (final r in await _db.select(_db.subtasks).get()) r.id: r.updatedAt},
        key: (r) => (r.id, r.updatedAt),
      ),
    );
    count(await _mergeOccurrences(backup.rowsOf('occurrences').map(OccurrenceRow.fromJson)));
    count(await _mergeChecks(backup.rowsOf('subtaskChecks').map(SubtaskCheckRow.fromJson)));
    return BackupImportResult(added: added, updated: updated);
  });

  /// Rows with an id: added when missing, replaced when newer.
  Future<(int, int)> _mergeById<R extends Insertable<R>>({
    required TableInfo<Table, R> table,
    required Iterable<R> rows,
    required Map<String, DateTime> local,
    required (String, DateTime) Function(R row) key,
  }) async {
    var added = 0;
    var updated = 0;
    for (final row in rows) {
      final (id, updatedAt) = key(row);
      final existing = local[id];
      if (existing == null) {
        await _db.into(table).insert(row);
        local[id] = updatedAt;
        added++;
      } else if (updatedAt.isAfter(existing)) {
        await _db.into(table).insertOnConflictUpdate(row);
        local[id] = updatedAt;
        updated++;
      }
    }
    return (added, updated);
  }

  /// Occurrences, matched by activity and day: the newer one wins and keeps
  /// the local id, so nothing is duplicated.
  Future<(int, int)> _mergeOccurrences(Iterable<OccurrenceRow> rows) async {
    final local = {
      for (final r in await _db.select(_db.occurrences).get()) (r.activityId, r.date): r,
    };
    var added = 0;
    var updated = 0;
    for (final row in rows) {
      final key = (row.activityId, row.date);
      final existing = local[key];
      if (existing == null) {
        await _db.into(_db.occurrences).insertOnConflictUpdate(row);
        local[key] = row;
        added++;
      } else if (row.updatedAt.isAfter(existing.updatedAt)) {
        final merged = row.copyWith(id: existing.id);
        await _db.into(_db.occurrences).insertOnConflictUpdate(merged);
        local[key] = merged;
        updated++;
      }
    }
    return (added, updated);
  }

  /// Subtask checks: added when missing (a check has nothing to update).
  Future<(int, int)> _mergeChecks(Iterable<SubtaskCheckRow> rows) async {
    final local = {
      for (final r in await _db.select(_db.subtaskChecks).get()) (r.subtaskId, r.date),
    };
    var added = 0;
    for (final row in rows) {
      if (local.add((row.subtaskId, row.date))) {
        await _db.into(_db.subtaskChecks).insert(row);
        added++;
      }
    }
    return (added, 0);
  }
}
