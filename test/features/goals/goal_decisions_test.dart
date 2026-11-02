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
import 'package:yoo/features/goals/data/drift_goal_repository.dart';
import 'package:yoo/features/goals/domain/goal_service.dart';
import 'package:yoo/features/goals/domain/monthly_goal.dart';

import '../../helpers/fixtures.dart';

/// Records "goal reached" notifications.
class _RecordingNotifier implements GoalCompletionNotifier {
  final reached = <String>[];

  @override
  Future<void> notifyGoalReached(MonthlyGoal goal) async => reached.add(goal.title);
}

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late DriftActivityRepository activities;
  late DriftGoalRepository goalRepository;
  late ActivityService service;
  late GoalService goals;
  late _RecordingNotifier notifier;

  final september = LocalDate(2026, 9, 29);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime(2026, 9, 29, 10));
    activities = DriftActivityRepository(db);
    goalRepository = DriftGoalRepository(db);
    final occurrences = DriftOccurrenceRepository(db);
    notifier = _RecordingNotifier();
    final ids = sequentialIds();
    goals = GoalService(
      goals: goalRepository,
      activities: activities,
      occurrences: occurrences,
      clock: clock,
      newId: ids,
      notifier: notifier,
    );
    service = ActivityService(
      activities: activities,
      occurrences: occurrences,
      store: DriftKeyValueStore(db),
      clock: clock,
      newId: ids,
      onChanged: (days) async {
        for (final (y, m) in {for (final d in days) (d.year, d.month)}) {
          await goals.checkCompletions(y, m);
        }
      },
    );
  });

  tearDown(() => db.close());

  Future<Activity> linkedTo(MonthlyGoal goal, String name) => service.create(
    ActivityDraft(
      name: name,
      notificationText: name,
      borderColorIndex: 0,
      recurrence: const DailyRecurrence(),
      timeSlots: const [TimeSlot.at(LocalTime(9, 0))],
      startDate: september,
      goalLink: GoalLink(goalId: goal.id, impact: 1, type: ImpactType.additive),
    ),
  );

  Future<GoalProgress> progressOf(MonthlyGoal goal) async =>
      (await goals.progressOfMonth(goal.year, goal.month)).singleWhere((p) => p.goal.id == goal.id);

  void goTo(DateTime now) => clock.current = now;

  test('a goal can be marked as completed by hand, without notification, and reopened', () async {
    final dentist = await goals.create(year: 2026, month: 9, title: 'Dentist');
    await goals.markCompleted(dentist);

    var p = await progressOf(dentist);
    expect(p.goal.outcome, GoalOutcome.completed);
    expect(p.isReached, isTrue);
    expect(p.fraction, 1);
    expect(notifier.reached, isEmpty);
    // Later changes never send a "goal reached" notification for it.
    await goals.checkCompletions(2026, 9);
    expect(notifier.reached, isEmpty);

    await goals.reopen(p.goal);
    p = await progressOf(dentist);
    expect(p.goal.outcome, isNull);
    expect(p.isReached, isFalse);
    expect(p.goal.completionNotifiedAt, isNull);
  });

  test('a goal whose month is over waits for a decision until one is taken', () async {
    final books = await goals.create(year: 2026, month: 9, title: 'Read 4 books', target: 4);
    final done = await goals.create(year: 2026, month: 9, title: 'Walk', target: 1);
    final walk = await linkedTo(done, 'Walk');
    await service.markTimeDone(walk.id, september);
    // September is still running: nothing to decide.
    expect(await goals.toDecide(), isEmpty);

    goTo(DateTime(2026, 10, 2, 9));
    final pending = await goals.toDecide();
    // The reached goal needs no decision.
    expect(pending.map((p) => p.goal.title), ['Read 4 books']);
    expect(pending.single.needsDecisionAt(LocalDate(2026, 10, 2)), isTrue);

    await goals.leaveIncomplete(pending.single.goal);
    expect(await goals.toDecide(), isEmpty);
    expect((await progressOf(books)).goal.outcome, GoalOutcome.leftIncomplete);
  });

  test('moving a goal continues it from zero next month, with its activities', () async {
    final books = await goals.create(year: 2026, month: 9, title: 'Read 4 books', target: 4);
    final reading = await linkedTo(books, 'Read');
    await service.markTimeDone(reading.id, september);
    await service.markTimeDone(reading.id, september.addDays(1));
    expect((await progressOf(books)).progress, 2);

    expect(goals.moveTargetFor(books), (2026, 10));
    final copy = (await goals.moveToNextMonth(books))!;
    expect((copy.year, copy.month), (2026, 10));
    expect(copy.title, 'Read 4 books');
    expect(copy.target, 4);
    expect(copy.movedFromId, books.id);

    // September keeps what it reached, even though the activity moved on.
    final old = await progressOf(books);
    expect(old.goal.outcome, GoalOutcome.moved);
    expect(old.goal.movedTo, (2026, 10));
    expect(old.progress, 2);
    expect((await activities.getById(reading.id))!.goalLink!.goalId, copy.id);

    // October starts from zero and is fed by the activity.
    expect((await progressOf(copy)).progress, 0);
    goTo(DateTime(2026, 10, 3, 9));
    await service.rollover();
    await service.markTimeDone(reading.id, LocalDate(2026, 10, 3));
    expect((await progressOf(copy)).progress, 1);
    expect((await progressOf(books)).progress, 2);

    // A moved goal cannot be moved, completed or reopened again.
    expect(await goals.moveToNextMonth(old.goal), isNull);
    await goals.markCompleted(old.goal);
    await goals.reopen(old.goal);
    expect((await progressOf(books)).goal.outcome, GoalOutcome.moved);
  });

  test('a goal of a month long over moves to the current month', () async {
    final july = await goals.create(year: 2026, month: 7, title: 'Paint the fence');
    expect(goals.moveTargetFor(july), (2026, 9));
    final copy = (await goals.moveToNextMonth(july))!;
    expect((copy.year, copy.month), (2026, 9));
    expect((await goalRepository.getById(july.id))!.movedTo, (2026, 9));
  });

  test('December moves to January', () {
    expect(MonthlyGoal.moveTarget(2026, 12, LocalDate(2026, 12, 10)), (2027, 1));
  });

  test('a goal can also be added to this month: per-day targets follow the days', () {
    MonthlyGoal goal(int month, int target) => MonthlyGoal(
      id: 'g',
      year: 2026,
      month: month,
      title: 'Creatine',
      target: target,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    expect(GoalService.adaptedTarget(goal(10, 31), 2026, 11), 30);
    expect(GoalService.adaptedTarget(goal(11, 30), 2027, 2), 28);
    expect(GoalService.adaptedTarget(goal(10, 5), 2026, 11), 5);
  });

  test('adding to this month keeps the old goal as it was and moves the activities', () async {
    final creatine = await goals.create(year: 2026, month: 9, title: 'Creatine', target: 30);
    final taking = await linkedTo(creatine, 'Take creatine');
    await service.markTimeDone(taking.id, september);
    expect((await progressOf(creatine)).progress, 1);

    goTo(DateTime(2026, 10, 1, 9));
    await service.rollover();
    final copy = (await goals.addToCurrentMonth(creatine, title: 'Creatine', target: 31))!;
    expect((copy.year, copy.month, copy.target), (2026, 10, 31));
    expect((await activities.getById(taking.id))!.goalLink!.goalId, copy.id);

    // September keeps its progress and still waits for a decision.
    final old = await progressOf(creatine);
    expect(old.progress, 1);
    expect(old.goal.outcome, isNull);
    await goals.leaveIncomplete(old.goal);
    expect((await progressOf(creatine)).progress, 1);
    await goals.reopen((await progressOf(creatine)).goal);
    expect((await progressOf(creatine)).progress, 1);

    await service.markTimeDone(taking.id, LocalDate(2026, 10, 1));
    expect((await progressOf(copy)).progress, 1);
    // Not for goals of this month.
    expect(await goals.addToCurrentMonth(copy, title: 'x', target: 1), isNull);
  });
}
