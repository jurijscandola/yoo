import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Activities. Structured fields that are always read together (recurrence,
/// time slots, partial config, goal link) are stored as JSON.
@DataClassName('ActivityRow')
class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get notificationText => text()();
  IntColumn get borderColorIndex => integer()();
  TextColumn get recurrenceJson => text()();
  TextColumn get timeSlotsJson => text()();
  TextColumn get startDate => text()();
  TextColumn get partialJson => text().nullable()();
  TextColumn get goalLinkJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Stored occurrences. Dates are ISO strings, so they sort and compare
/// correctly as text.
@DataClassName('OccurrenceRow')
@TableIndex(name: 'occurrences_date', columns: {#date})
@TableIndex(name: 'occurrences_activity_date', columns: {#activityId, #date})
class Occurrences extends Table {
  TextColumn get id => text()();
  TextColumn get activityId => text()();
  TextColumn get date => text()();
  TextColumn get originalDate => text()();
  TextColumn get status => text()();
  IntColumn get completedCount => integer().withDefault(const Constant(0))();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  TextColumn get resolution => text().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get retroactive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Monthly goals.
@DataClassName('GoalRow')
@TableIndex(name: 'goals_month', columns: {#year, #month})
class Goals extends Table {
  TextColumn get id => text()();
  IntColumn get year => integer()();
  IntColumn get month => integer()();
  TextColumn get title => text()();
  DateTimeColumn get completionNotifiedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Generic key/value pairs (settings, bookkeeping).
@DataClassName('KeyValueRow')
class KeyValues extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

/// The local SQLite database of Yoo.
@DriftDatabase(tables: [Activities, Occurrences, Goals, KeyValues])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens the on-device database. It is shared across isolates, so the
  /// background notification handler and the UI see the same data.
  factory AppDatabase.open() => AppDatabase(
    driftDatabase(name: 'yoo', native: const DriftNativeOptions(shareAcrossIsolates: true)),
  );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // Future schema changes add `if (from < N)` steps here.
    onUpgrade: (m, from, to) async {},
  );
}
