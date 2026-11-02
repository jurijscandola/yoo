import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/core/database/app_database.dart';
import 'package:yoo/core/database/drift_key_value_store.dart';
import 'package:yoo/core/time/clock.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/core/time/local_time.dart';
import 'package:yoo/features/activities/data/drift_activity_repository.dart';
import 'package:yoo/features/activities/data/drift_occurrence_repository.dart';
import 'package:yoo/features/activities/data/drift_subtask_repository.dart';
import 'package:yoo/features/activities/domain/entities/activity.dart';
import 'package:yoo/features/activities/domain/entities/activity_draft.dart';
import 'package:yoo/features/activities/domain/entities/occurrence.dart';
import 'package:yoo/features/activities/domain/entities/recurrence.dart';
import 'package:yoo/features/activities/domain/entities/subtask.dart';
import 'package:yoo/features/activities/domain/services/activity_service.dart';
import 'package:yoo/features/backup/data/drift_backup_store.dart';
import 'package:yoo/features/backup/domain/backup_file.dart';
import 'package:yoo/features/backup/domain/backup_service.dart';
import 'package:yoo/features/goals/data/drift_goal_repository.dart';
import 'package:yoo/features/goals/domain/goal_service.dart';
import 'package:yoo/features/settings/data/stored_settings_repository.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';

import '../../helpers/fixtures.dart';

/// One app instance on an in-memory database.
class _Device {
  _Device(DateTime now) : db = AppDatabase(NativeDatabase.memory()), clock = FixedClock(now) {
    final ids = sequentialIds();
    activities = DriftActivityRepository(db);
    occurrences = DriftOccurrenceRepository(db);
    settings = StoredSettingsRepository(DriftKeyValueStore(db));
    goals = GoalService(
      goals: DriftGoalRepository(db),
      activities: activities,
      occurrences: occurrences,
      clock: clock,
      newId: ids,
    );
    service = ActivityService(
      activities: activities,
      occurrences: occurrences,
      store: DriftKeyValueStore(db),
      clock: clock,
      newId: ids,
    );
    backup = BackupService(
      store: DriftBackupStore(db),
      settings: settings,
      clock: clock,
      afterImport: () async => imports++,
    );
  }

  final AppDatabase db;
  final FixedClock clock;
  late final DriftActivityRepository activities;
  late final DriftOccurrenceRepository occurrences;
  late final StoredSettingsRepository settings;
  late final GoalService goals;
  late final ActivityService service;
  late final BackupService backup;
  var imports = 0;

  /// Every row of every table, comparable across databases.
  Future<Map<String, Object?>> dump() async => {
    'activities': [for (final r in await db.select(db.activities).get()) r.toJson()],
    'occurrences': [for (final r in await db.select(db.occurrences).get()) r.toJson()],
    'goals': [for (final r in await db.select(db.goals).get()) r.toJson()],
    'subtasks': [for (final r in await db.select(db.subtasks).get()) r.toJson()],
    'subtaskChecks': [for (final r in await db.select(db.subtaskChecks).get()) r.toJson()],
  };
}

void main() {
  final today = LocalDate(2026, 9, 29);
  final devices = <_Device>[];

  _Device device([DateTime? now]) {
    final d = _Device(now ?? DateTime(2026, 9, 29, 10));
    devices.add(d);
    return d;
  }

  tearDown(() async {
    for (final d in devices) {
      await d.db.close();
    }
    devices.clear();
  });

  ActivityDraft draft(String name, {GoalLink? goalLink, PartialConfig? partial}) => ActivityDraft(
    name: name,
    notificationText: 'Time for $name',
    borderColorIndex: 4,
    recurrence: const DailyRecurrence(),
    timeSlots: const [TimeSlot(from: LocalTime(8, 0), to: LocalTime(9, 30))],
    startDate: today.addDays(-3),
    goalLink: goalLink,
    partial: partial,
  );

  /// A device with a bit of everything: history, a deleted activity, a
  /// decided goal, subtasks with checks and custom settings.
  Future<_Device> filledDevice() async {
    final d = device(DateTime(2026, 9, 26, 10));
    final books = await d.goals.create(year: 2026, month: 9, title: 'Read 4 books', target: 4);
    final dentist = await d.goals.create(year: 2026, month: 9, title: 'Dentist');
    final read = await d.service.create(
      draft(
        'Read',
        goalLink: GoalLink(goalId: books.id, impact: 1, type: ImpactType.additive),
      ),
    );
    final plants = await d.service.create(draft('Water the plants'));
    final study = await d.service.create(
      draft('Study', partial: const PartialConfig(reminderCount: 2, until: LocalTime(20, 0))),
    );
    final old = await d.service.create(draft('Old habit'));
    await d.service.markTimeDone(read.id, LocalDate(2026, 9, 26));
    for (var day = 27; day <= 29; day++) {
      d.clock.current = DateTime(2026, 9, day, 10);
      await d.service.rollover();
    }
    await d.service.markNotNeeded(plants.id, today);
    await d.service.setProgress(study.id, today, 40);
    await d.service.deleteActivity(old.id);
    await d.goals.markCompleted(dentist);

    final subtasks = DriftSubtaskRepository(d.db);
    await subtasks.save(
      Subtask(
        id: 'sub-1',
        activityId: read.id,
        title: 'Chapter 1',
        position: 0,
        createdAt: d.clock.now(),
        updatedAt: d.clock.now(),
      ),
    );
    await subtasks.setChecked('sub-1', today, checked: true);
    await d.settings.save(
      const AppSettings(
        localeCode: 'it',
        theme: ThemeConfig(presetId: 'night', cardStyle: CardStyle.paper),
        appIconId: 'ocean',
      ),
    );
    return d;
  }

  test('a backup restores everything on an empty phone', () async {
    final old = await filledDevice();
    final text = await old.backup.export();
    expect(old.backup.fileName(), 'Yoo-backup-2026-09-29.json');

    final fresh = device();
    final file = fresh.backup.read(text);
    expect(file.activityCount, 3); // the deleted one is history only
    expect(file.dayCount, 4);
    expect(file.goalCount, 2);

    final result = await fresh.backup.restore(file);
    expect(result.updated, 0);
    expect(result.added, greaterThan(10));
    expect(fresh.imports, 1);
    expect(await fresh.dump(), await old.dump());

    // Language and appearance come along; the app icon belongs to the device.
    final settings = await fresh.settings.load();
    expect(settings.localeCode, 'it');
    expect(settings.theme.presetId, 'night');
    expect(settings.theme.cardStyle, CardStyle.paper);
    expect(settings.appIconId, AppSettings.defaultAppIconId);

    // Importing the same file again changes nothing.
    final again = await fresh.backup.restore(fresh.backup.read(text));
    expect((again.added, again.updated), (0, 0));
    expect(await fresh.dump(), await old.dump());
  });

  test('importing never deletes and never overwrites newer local data', () async {
    final phone = await filledDevice();
    final text = await phone.backup.export();
    final read = (await phone.activities.getAll()).firstWhere((a) => a.name == 'Read');

    // After the backup: a new activity, a renamed one, and today ticked.
    phone.clock.current = DateTime(2026, 9, 29, 18);
    final walk = await phone.service.create(draft('Walk'));
    final renamed = await phone.service.update(
      read,
      ActivityDraft(
        name: 'Read more',
        notificationText: read.notificationText,
        borderColorIndex: read.borderColorIndex,
        recurrence: read.recurrence,
        timeSlots: read.timeSlots,
        startDate: read.startDate,
        goalLink: read.goalLink,
      ),
    );
    await phone.service.markTimeDone(read.id, today);

    final result = await phone.backup.restore(phone.backup.read(text));
    expect((result.added, result.updated), (0, 0));
    expect((await phone.activities.getById(walk.id))!.name, 'Walk');
    expect((await phone.activities.getById(renamed.id))!.name, 'Read more');
    expect((await phone.occurrences.find(read.id, today))!.isCompleted, isTrue);
  });

  test('occurrences are matched by activity and day, newer wins, no duplicates', () async {
    final old = await filledDevice();
    final text = await old.backup.export();
    final plants = (await old.activities.getAll()).firstWhere((a) => a.name == 'Water the plants');

    // Another phone got the activities earlier and stored its own today's
    // occurrence (another id, older) before this backup is imported.
    final other = device(DateTime(2026, 9, 29, 7));
    await other.db
        .into(other.db.activities)
        .insert(
          (await old.db.select(old.db.activities).get()).firstWhere((r) => r.id == plants.id),
        );
    await other.occurrences.saveAll([
      Occurrence(
        id: 'local-today',
        activityId: plants.id,
        date: today,
        originalDate: today,
        updatedAt: DateTime(2026, 9, 29, 7),
      ),
    ]);

    await other.backup.restore(other.backup.read(text));
    final todays = (await other.occurrences.getBetween(
      today,
      today,
    )).where((o) => o.activityId == plants.id).toList();
    expect(todays, hasLength(1));
    expect(todays.single.id, 'local-today');
    expect(todays.single.status, OccurrenceStatus.notNeeded);
  });

  test('files that are not backups, or come from a newer Yoo, are refused', () {
    final d = device();
    BackupProblem problemOf(String text) {
      try {
        d.backup.read(text);
      } on BackupFormatException catch (e) {
        return e.problem;
      }
      fail('accepted: $text');
    }

    expect(problemOf('Yoo · September 2026\r\nGOALS'), BackupProblem.invalid);
    expect(problemOf('{"format":"other"}'), BackupProblem.invalid);
    expect(problemOf('{"format":"yoo-backup","version":1}'), BackupProblem.invalid);
    final tooNew = jsonEncode({
      'format': 'yoo-backup',
      'version': 1,
      'schemaVersion': d.db.schemaVersion + 1,
      'exportedAt': '2027-01-01T00:00:00Z',
      'tables': <String, Object?>{},
    });
    expect(problemOf(tooNew), BackupProblem.tooNew);
  });

  test('a byte order mark added by an editor is ignored', () async {
    final d = await filledDevice();
    final text = await d.backup.export();
    expect(d.backup.read('﻿$text').activityCount, 3);
  });
}
