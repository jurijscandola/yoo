import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/time/local_date.dart';
import '../domain/entities/occurrence.dart';
import '../domain/repositories/occurrence_repository.dart';

/// [OccurrenceRepository] backed by the local Drift database.
class DriftOccurrenceRepository implements OccurrenceRepository {
  DriftOccurrenceRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$OccurrencesTable, OccurrenceRow> _between(LocalDate from, LocalDate to) =>
      _db.select(_db.occurrences)
        ..where((t) => t.date.isBetweenValues(from.toString(), to.toString()))
        ..orderBy([(t) => OrderingTerm.asc(t.date)]);

  SimpleSelectStatement<$OccurrencesTable, OccurrenceRow> _unresolved() =>
      _db.select(_db.occurrences)..where(
        (t) =>
            t.status.equals(OccurrenceStatus.missed.name) &
            t.resolution.equals(MissedResolution.unresolved.name),
      );

  @override
  Stream<List<Occurrence>> watchBetween(LocalDate from, LocalDate to) =>
      _between(from, to).watch().map(_map);

  @override
  Future<List<Occurrence>> getBetween(LocalDate from, LocalDate to) async =>
      _map(await _between(from, to).get());

  @override
  Future<List<Occurrence>> getFrom(LocalDate from) async {
    final q = _db.select(_db.occurrences)
      ..where((t) => t.date.isBiggerOrEqualValue(from.toString()));
    return _map(await q.get());
  }

  @override
  Stream<List<Occurrence>> watchUnresolvedMissed() => _unresolved().watch().map(_map);

  @override
  Future<List<Occurrence>> getUnresolvedMissed() async => _map(await _unresolved().get());

  @override
  Future<Occurrence?> find(String activityId, LocalDate date) async {
    final row =
        await (_db.select(_db.occurrences)
              ..where((t) => t.activityId.equals(activityId) & t.date.equals(date.toString()))
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : occurrenceFromRow(row);
  }

  @override
  Future<Occurrence?> getById(String id) async {
    final row = await (_db.select(
      _db.occurrences,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : occurrenceFromRow(row);
  }

  @override
  Future<void> saveAll(List<Occurrence> occurrences) async {
    if (occurrences.isEmpty) return;
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(_db.occurrences, occurrences.map(occurrenceToRow).toList());
    });
  }

  List<Occurrence> _map(List<OccurrenceRow> rows) => rows.map(occurrenceFromRow).toList();
}

/// Maps a database row to the domain entity.
Occurrence occurrenceFromRow(OccurrenceRow row) => Occurrence(
  id: row.id,
  activityId: row.activityId,
  date: LocalDate.parse(row.date),
  originalDate: LocalDate.parse(row.originalDate),
  status: OccurrenceStatus.values.byName(row.status),
  completedCount: row.completedCount,
  progress: row.progress,
  resolution: row.resolution == null ? null : MissedResolution.values.byName(row.resolution!),
  completedAt: row.completedAt,
  retroactive: row.retroactive,
  updatedAt: row.updatedAt,
);

/// Maps the domain entity to an insertable row.
OccurrencesCompanion occurrenceToRow(Occurrence o) => OccurrencesCompanion.insert(
  id: o.id,
  activityId: o.activityId,
  date: o.date.toString(),
  originalDate: o.originalDate.toString(),
  status: o.status.name,
  completedCount: Value(o.completedCount),
  progress: Value(o.progress),
  resolution: Value(o.resolution?.name),
  completedAt: Value(o.completedAt),
  retroactive: Value(o.retroactive),
  updatedAt: o.updatedAt,
);
