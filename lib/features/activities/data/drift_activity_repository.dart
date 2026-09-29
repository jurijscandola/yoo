import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/time/local_date.dart';
import '../domain/entities/activity.dart';
import '../domain/entities/recurrence.dart';
import '../domain/repositories/activity_repository.dart';

/// [ActivityRepository] backed by the local Drift database.
class DriftActivityRepository implements ActivityRepository {
  DriftActivityRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$ActivitiesTable, ActivityRow> _query(bool includeDeleted) {
    final q = _db.select(_db.activities);
    if (!includeDeleted) q.where((t) => t.deletedAt.isNull());
    return q..orderBy([(t) => OrderingTerm.asc(t.name)]);
  }

  @override
  Stream<List<Activity>> watchAll({bool includeDeleted = false}) =>
      _query(includeDeleted).watch().map((rows) => rows.map(activityFromRow).toList());

  @override
  Future<List<Activity>> getAll({bool includeDeleted = false}) async =>
      (await _query(includeDeleted).get()).map(activityFromRow).toList();

  @override
  Future<Activity?> getById(String id) async {
    final row = await (_db.select(
      _db.activities,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : activityFromRow(row);
  }

  @override
  Future<void> save(Activity activity) =>
      _db.into(_db.activities).insertOnConflictUpdate(activityToRow(activity));
}

/// Maps a database row to the domain entity.
Activity activityFromRow(ActivityRow row) {
  Map<String, Object?> obj(String raw) => jsonDecode(raw) as Map<String, Object?>;
  return Activity(
    id: row.id,
    name: row.name,
    notificationText: row.notificationText,
    borderColorIndex: row.borderColorIndex,
    recurrence: Recurrence.fromJson(obj(row.recurrenceJson)),
    timeSlots: [
      for (final s in jsonDecode(row.timeSlotsJson) as List<Object?>)
        TimeSlot.fromJson(s! as Map<String, Object?>),
    ],
    startDate: LocalDate.parse(row.startDate),
    partial: row.partialJson == null ? null : PartialConfig.fromJson(obj(row.partialJson!)),
    goalLink: row.goalLinkJson == null ? null : GoalLink.fromJson(obj(row.goalLinkJson!)),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
  );
}

/// Maps the domain entity to an insertable row.
ActivitiesCompanion activityToRow(Activity a) => ActivitiesCompanion.insert(
  id: a.id,
  name: a.name,
  notificationText: a.notificationText,
  borderColorIndex: a.borderColorIndex,
  recurrenceJson: jsonEncode(a.recurrence.toJson()),
  timeSlotsJson: jsonEncode([for (final s in a.timeSlots) s.toJson()]),
  startDate: a.startDate.toString(),
  partialJson: Value(a.partial == null ? null : jsonEncode(a.partial!.toJson())),
  goalLinkJson: Value(a.goalLink == null ? null : jsonEncode(a.goalLink!.toJson())),
  createdAt: a.createdAt,
  updatedAt: a.updatedAt,
  deletedAt: Value(a.deletedAt),
);
