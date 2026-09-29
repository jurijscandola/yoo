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
import 'package:yoo/features/activities/domain/entities/occurrence.dart';
import 'package:yoo/features/activities/domain/entities/recurrence.dart';
import 'package:yoo/features/activities/domain/services/activity_service.dart';
import 'package:yoo/features/reminders/application/notification_action_handler.dart';
import 'package:yoo/features/reminders/application/reminder_scheduler.dart';
import 'package:yoo/features/reminders/domain/notification_planner.dart';
import 'package:yoo/features/reminders/domain/reminder_gateway.dart';

import '../../../helpers/fake_reminder_gateway.dart';
import '../../../helpers/fixtures.dart';

void main() {
  final today = LocalDate(2026, 9, 29);

  late AppDatabase db;
  late DriftOccurrenceRepository occurrences;
  late FakeReminderGateway gateway;
  late ActivityService service;
  late NotificationActionHandler handler;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    gateway = FakeReminderGateway();
    final clock = FixedClock(DateTime(2026, 9, 29, 10));
    final activities = DriftActivityRepository(db);
    occurrences = DriftOccurrenceRepository(db);
    final scheduler = ReminderScheduler(
      activities: activities,
      occurrences: occurrences,
      gateway: gateway,
      clock: clock,
      labels: () async => const ReminderLabels(
        done: 'Done',
        full: '100%',
        half: '50%',
        other: 'Other %',
        inputLabel: 'Percentage',
      ),
    );
    // Same wiring as the app: every change refreshes the reminders.
    service = ActivityService(
      activities: activities,
      occurrences: occurrences,
      store: DriftKeyValueStore(db),
      clock: clock,
      newId: sequentialIds(),
      onChanged: (_) => scheduler.refresh(),
    );
    handler = NotificationActionHandler(service);
  });

  tearDown(() => db.close());

  Future<Activity> create(String name, {int times = 1, PartialConfig? partial}) {
    return service.create(
      ActivityDraft(
        name: name,
        notificationText: 'Time for $name',
        borderColorIndex: 0,
        recurrence: const DailyRecurrence(),
        timeSlots: [for (var i = 0; i < times; i++) TimeSlot.at(LocalTime(12 + i, 0))],
        startDate: today,
        partial: partial,
      ),
    );
  }

  String payload(Activity a, [LocalDate? day]) =>
      ReminderPayload(activityId: a.id, date: day ?? today).encode();

  Future<Occurrence> todayOf(Activity a) async =>
      (await occurrences.getBetween(today, today)).singleWhere((o) => o.activityId == a.id);

  test('"Done" counts one time and completes the last one', () async {
    final a = await create('Vitamins', times: 2);

    expect(await handler.handle(actionId: ReminderActions.done, payload: payload(a)), isTrue);
    expect((await todayOf(a)).completedCount, 1);
    expect((await todayOf(a)).status, OccurrenceStatus.pending);

    await handler.handle(actionId: ReminderActions.done, payload: payload(a));
    expect((await todayOf(a)).status, OccurrenceStatus.completed);
    // The change hook refreshed the schedule: nothing left for today.
    expect(gateway.pending.values.where((r) => r.activityId == a.id && r.date == today), isEmpty);
  });

  test('percentage actions set the progress of partial activities', () async {
    final a = await create(
      'Study',
      partial: const PartialConfig(reminderCount: 1, until: LocalTime(20, 0)),
    );

    await handler.handle(actionId: ReminderActions.half, payload: payload(a));
    expect((await todayOf(a)).progress, 50);

    await handler.handle(actionId: ReminderActions.input, payload: payload(a), input: ' 40% ');
    expect((await todayOf(a)).progress, 40);

    await handler.handle(actionId: ReminderActions.full, payload: payload(a));
    expect((await todayOf(a)).progress, 100);
    expect((await todayOf(a)).status, OccurrenceStatus.completed);
  });

  test('typed percentages are clamped; empty input changes nothing', () async {
    final a = await create(
      'Run',
      partial: const PartialConfig(reminderCount: 0, until: LocalTime(20, 0)),
    );
    await handler.handle(actionId: ReminderActions.input, payload: payload(a), input: '250');
    expect((await todayOf(a)).progress, 100);

    final b = await create(
      'Swim',
      partial: const PartialConfig(reminderCount: 0, until: LocalTime(20, 0)),
    );
    expect(
      await handler.handle(actionId: ReminderActions.input, payload: payload(b), input: 'abc'),
      isFalse,
    );
    expect((await todayOf(b)).progress, 0);
  });

  test('taps, unknown actions and foreign payloads are ignored', () async {
    final a = await create('Walk');
    expect(await handler.handle(actionId: null, payload: payload(a)), isFalse);
    expect(await handler.handle(actionId: '', payload: payload(a)), isFalse);
    expect(await handler.handle(actionId: 'snooze', payload: payload(a)), isFalse);
    expect(await handler.handle(actionId: ReminderActions.done, payload: 'goal|x'), isFalse);
    expect(await handler.handle(actionId: ReminderActions.done, payload: null), isFalse);
    expect((await todayOf(a)).completedCount, 0);
  });

  test('an action on a future reminder creates that day\'s occurrence', () async {
    final a = await create('Water');
    final tomorrow = today.addDays(1);
    await handler.handle(actionId: ReminderActions.done, payload: payload(a, tomorrow));
    final stored = (await occurrences.getBetween(tomorrow, tomorrow)).single;
    expect(stored.activityId, a.id);
    expect(stored.status, OccurrenceStatus.completed);
  });
}
