import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/core/database/app_database.dart';
import 'package:yoo/core/database/drift_key_value_store.dart';
import 'package:yoo/core/time/clock.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/core/time/local_time.dart';
import 'package:yoo/features/activities/data/drift_activity_repository.dart';
import 'package:yoo/features/activities/data/drift_occurrence_repository.dart';
import 'package:yoo/features/activities/domain/entities/activity.dart';
import 'package:yoo/features/activities/domain/entities/activity_draft.dart';
import 'package:yoo/features/activities/domain/entities/recurrence.dart';
import 'package:yoo/features/activities/domain/services/activity_service.dart';
import 'package:yoo/features/reminders/application/reminder_scheduler.dart';
import 'package:yoo/features/reminders/domain/notification_planner.dart';
import 'package:yoo/features/reminders/domain/reminder_gateway.dart';

import '../../../helpers/fake_reminder_gateway.dart';
import '../../../helpers/fixtures.dart';

void main() {
  const labels = ReminderLabels(
    done: 'Done',
    full: '100%',
    half: '50%',
    other: 'Other %',
    inputLabel: 'Percentage',
  );
  final today = LocalDate(2026, 9, 29);

  late AppDatabase db;
  late FakeReminderGateway gateway;
  late ReminderScheduler scheduler;
  late ActivityService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    gateway = FakeReminderGateway();
    final clock = FixedClock(DateTime(2026, 9, 29, 10));
    final activities = DriftActivityRepository(db);
    final occurrences = DriftOccurrenceRepository(db);
    scheduler = ReminderScheduler(
      activities: activities,
      occurrences: occurrences,
      gateway: gateway,
      clock: clock,
      labels: () async => labels,
      planner: const NotificationPlanner(horizonDays: 2),
    );
    service = ActivityService(
      activities: activities,
      occurrences: occurrences,
      store: DriftKeyValueStore(db),
      clock: clock,
      newId: sequentialIds(),
    );
  });

  tearDown(() => db.close());

  Future<Activity> create(String name, {List<TimeSlot>? slots, PartialConfig? partial}) {
    return service.create(
      ActivityDraft(
        name: name,
        notificationText: 'Time for $name',
        borderColorIndex: 0,
        recurrence: const DailyRecurrence(),
        timeSlots: slots ?? const [TimeSlot.at(LocalTime(12, 0))],
        startDate: today,
        partial: partial,
      ),
    );
  }

  List<PlannedReminder> pendingOf(String activityId, LocalDate day) =>
      gateway.pending.values.where((r) => r.activityId == activityId && r.date == day).toList();

  test('schedules the planned reminders with the localized labels', () async {
    final a = await create('Vitamins');
    await scheduler.refresh();

    // 12:00 today and tomorrow (2-day horizon), carrying the occurrence payload.
    expect(gateway.pending.values.map((r) => r.date), unorderedEquals([today, today.addDays(1)]));
    final first = pendingOf(a.id, today).single;
    expect(first.title, 'Yoo! Vitamins');
    expect(first.body, 'Time for Vitamins');
    expect(ReminderPayload.tryDecode(first.payload)?.activityId, a.id);
    expect(gateway.lastLabels, same(labels));
  });

  test('cancels reminders that are no longer planned and keeps the others', () async {
    final a = await create('Walk');
    gateway.pending[42] = PlannedReminder(
      id: 42,
      activityId: 'gone',
      date: today,
      time: const LocalTime(20, 0),
      kind: ReminderKind.slot,
      index: 0,
      title: 'Old',
      body: 'Old',
      isPartial: false,
    );
    await scheduler.refresh();
    expect(gateway.cancelled, [42]);
    expect(gateway.pending.keys, isNot(contains(42)));
    expect(pendingOf(a.id, today), hasLength(1));
  });

  test('refresh is idempotent: stable ids, nothing cancelled', () async {
    await create(
      'Read',
      slots: const [TimeSlot(from: LocalTime(14, 0), to: LocalTime(18, 0))],
    );
    await scheduler.refresh();
    final first = Map.of(gateway.pending);
    await scheduler.refresh();
    expect(gateway.cancelled, isEmpty);
    expect(gateway.pending.keys, first.keys);
    for (final id in first.keys) {
      expect(gateway.pending[id]!.localDateTime, first[id]!.localDateTime);
    }
  });

  test('completed occurrences lose their reminders', () async {
    final a = await create(
      'Stretch',
      slots: const [TimeSlot.at(LocalTime(12, 0)), TimeSlot.at(LocalTime(18, 0))],
    );
    await scheduler.refresh();
    expect(pendingOf(a.id, today), hasLength(2));

    await service.markTimeDone(a.id, today);
    await scheduler.refresh();
    expect(pendingOf(a.id, today), hasLength(1));

    await service.markTimeDone(a.id, today);
    await scheduler.refresh();
    expect(pendingOf(a.id, today), isEmpty);
    // Tomorrow is untouched.
    expect(pendingOf(a.id, today.addDays(1)), hasLength(2));
  });

  test('partial activities get follow-ups until they reach 100%', () async {
    final a = await create(
      'Study',
      partial: const PartialConfig(reminderCount: 2, until: LocalTime(20, 0)),
    );
    await scheduler.refresh();
    final todays = pendingOf(a.id, today);
    expect(todays, hasLength(3));
    expect(todays.every((r) => r.isPartial), isTrue);
    expect(todays.where((r) => r.kind == ReminderKind.followUp), hasLength(2));

    await service.setProgress(a.id, today, 60);
    await scheduler.refresh();
    expect(pendingOf(a.id, today), hasLength(3));

    await service.setProgress(a.id, today, 100);
    await scheduler.refresh();
    expect(pendingOf(a.id, today), isEmpty);
  });

  test('concurrent refreshes are coalesced into one extra run', () async {
    await create('Water');
    gateway.gate = Completer<void>();
    final runs = [scheduler.refresh(), scheduler.refresh(), scheduler.refresh()];
    gateway.gate!.complete();
    await Future.wait(runs);
    expect(gateway.refreshRuns, 2);

    // Once idle, a new call runs again.
    await scheduler.refresh();
    expect(gateway.refreshRuns, 3);
  });
}
