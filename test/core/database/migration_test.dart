import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/core/database/app_database.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/features/activities/data/drift_activity_repository.dart';
import 'package:yoo/features/activities/data/drift_subtask_repository.dart';
import 'package:yoo/features/activities/domain/entities/subtask.dart';
import 'package:yoo/features/goals/data/drift_goal_repository.dart';

/// Schema 1 as shipped, with some user data in it.
const _schema1 = [
  'CREATE TABLE activities (id TEXT NOT NULL, name TEXT NOT NULL, '
      'notification_text TEXT NOT NULL, border_color_index INTEGER NOT NULL, '
      'recurrence_json TEXT NOT NULL, time_slots_json TEXT NOT NULL, start_date TEXT NOT NULL, '
      'partial_json TEXT NULL, goal_link_json TEXT NULL, created_at INTEGER NOT NULL, '
      'updated_at INTEGER NOT NULL, deleted_at INTEGER NULL, PRIMARY KEY (id))',
  'CREATE TABLE occurrences (id TEXT NOT NULL, activity_id TEXT NOT NULL, date TEXT NOT NULL, '
      'original_date TEXT NOT NULL, status TEXT NOT NULL, '
      'completed_count INTEGER NOT NULL DEFAULT 0, progress INTEGER NOT NULL DEFAULT 0, '
      'resolution TEXT NULL, completed_at INTEGER NULL, '
      'retroactive INTEGER NOT NULL DEFAULT 0 CHECK (retroactive IN (0, 1)), '
      'updated_at INTEGER NOT NULL, PRIMARY KEY (id))',
  'CREATE TABLE goals (id TEXT NOT NULL, year INTEGER NOT NULL, month INTEGER NOT NULL, '
      'title TEXT NOT NULL, completion_notified_at INTEGER NULL, created_at INTEGER NOT NULL, '
      'updated_at INTEGER NOT NULL, deleted_at INTEGER NULL, PRIMARY KEY (id))',
  'CREATE TABLE key_values ("key" TEXT NOT NULL, value TEXT NULL, PRIMARY KEY ("key"))',
  'CREATE INDEX occurrences_date ON occurrences (date)',
  'CREATE INDEX occurrences_activity_date ON occurrences (activity_id, date)',
  'CREATE INDEX goals_month ON goals (year, month)',
  "INSERT INTO activities VALUES ('a1', 'Pulire auto', 'Pulisci l''auto', 3, "
      '\'{"type":"weekly","weekday":6}\', \'[{"from":"09:00","to":"10:00"}]\', '
      "'2026-09-01', NULL, '{\"goalId\":\"g1\",\"impact\":25,\"type\":\"additive\"}', "
      '1788000000, 1788000000, NULL)',
  "INSERT INTO occurrences VALUES ('o1', 'a1', '2026-09-05', '2026-09-05', 'completed', "
      '1, 0, NULL, 1788000000, 0, 1788000000)',
  "INSERT INTO goals VALUES ('g1', 2026, 9, 'Auto pulita', NULL, 1788000000, 1788000000, NULL)",
  "INSERT INTO key_values VALUES ('theme', 'dark')",
];

void main() {
  test('upgrading from schema 1 keeps every activity, occurrence, goal and setting', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          for (final sql in _schema1) {
            raw.execute(sql);
          }
          raw.userVersion = 1;
        },
      ),
    );
    addTearDown(db.close);

    final activities = await DriftActivityRepository(db).getAll();
    expect(activities.map((a) => a.name), ['Pulire auto']);
    expect(activities.single.goalLink?.impact, 25);

    expect(await db.select(db.occurrences).get(), hasLength(1));

    final goal = await DriftGoalRepository(db).getById('g1');
    expect(goal?.title, 'Auto pulita');
    // Old goals were percentages: they keep 100 as target.
    expect(goal?.target, 100);

    final settings = await db.select(db.keyValues).get();
    expect(settings.single.value, 'dark');

    // The new tables are usable.
    final subtasks = DriftSubtaskRepository(db);
    await subtasks.save(
      Subtask(
        id: 's1',
        activityId: 'a1',
        title: 'Aspirapolvere',
        position: 0,
        createdAt: DateTime(2026, 9, 30),
        updatedAt: DateTime(2026, 9, 30),
      ),
    );
    final today = LocalDate(2026, 9, 30);
    await subtasks.setChecked('s1', today, checked: true);
    expect(await subtasks.watchChecked('a1', today).first, {'s1'});
    expect(await subtasks.watchChecked('a1', today.addDays(1)).first, isEmpty);
  });
}
