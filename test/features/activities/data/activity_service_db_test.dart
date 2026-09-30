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
import 'package:yoo/features/goals/data/drift_goal_repository.dart';
import 'package:yoo/features/goals/domain/goal_service.dart';
import 'package:yoo/features/goals/domain/monthly_goal.dart';
import 'package:yoo/features/settings/data/stored_settings_repository.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';

import '../../../helpers/fixtures.dart';

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
  late DriftOccurrenceRepository occurrences;
  late ActivityService service;
  late GoalService goals;
  late _RecordingNotifier notifier;
  late List<Set<LocalDate>> changes;

  final today = LocalDate(2026, 9, 29);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime(2026, 9, 29, 10));
    activities = DriftActivityRepository(db);
    occurrences = DriftOccurrenceRepository(db);
    notifier = _RecordingNotifier();
    changes = [];
    final ids = sequentialIds();
    goals = GoalService(
      goals: DriftGoalRepository(db),
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
        changes.add(days);
        for (final (y, m) in {for (final d in days) (d.year, d.month)}) {
          await goals.checkCompletions(y, m);
        }
      },
    );
  });

  tearDown(() => db.close());

  ActivityDraft draft(
    String name, {
    Recurrence recurrence = const DailyRecurrence(),
    List<TimeSlot> slots = const [TimeSlot(from: LocalTime(9, 0), to: LocalTime(11, 0))],
    PartialConfig? partial,
    GoalLink? goalLink,
  }) => ActivityDraft(
    name: name,
    notificationText: 'Time for $name',
    borderColorIndex: 3,
    recurrence: recurrence,
    timeSlots: slots,
    startDate: today,
    partial: partial,
    goalLink: goalLink,
  );

  test('activities round-trip through the database with all their fields', () async {
    final created = await service.create(
      draft(
        'Vitamins',
        recurrence: const SpecificDaysRecurrence(
          days: {1, 15},
          repeat: MonthRepeat.everyMonth,
          anchorYear: 2026,
          anchorMonth: 9,
        ),
        partial: const PartialConfig(reminderCount: 2, until: LocalTime(21, 30)),
        goalLink: const GoalLink(goalId: 'g', impact: 20, type: ImpactType.subtractive),
      ),
    );
    final loaded = (await activities.getById(created.id))!;
    expect(loaded.name, 'Vitamins');
    expect(loaded.recurrence, created.recurrence);
    expect(loaded.timeSlots, created.timeSlots);
    expect(loaded.partial!.until, const LocalTime(21, 30));
    expect(loaded.goalLink!.type, ImpactType.subtractive);
    expect(loaded.startDate, today);
  });

  test('creating an activity planned today stores today\'s occurrence', () async {
    final a = await service.create(draft('Water'));
    final stored = await occurrences.find(a.id, today);
    expect(stored, isNotNull);
    expect(stored!.isOpen, isTrue);
    expect(changes.single, {today});
  });

  test('marking every time done completes the occurrence', () async {
    final a = await service.create(
      draft('Stretch', slots: const [TimeSlot.at(LocalTime(9, 0)), TimeSlot.at(LocalTime(18, 0))]),
    );
    await service.markTimeDone(a.id, today);
    expect((await occurrences.find(a.id, today))!.completedCount, 1);
    await service.markTimeDone(a.id, today);
    expect((await occurrences.find(a.id, today))!.isCompleted, isTrue);
  });

  test('a completion by mistake can be undone today', () async {
    final a = await service.create(
      draft('Stretch', slots: const [TimeSlot.at(LocalTime(9, 0)), TimeSlot.at(LocalTime(18, 0))]),
    );
    final p = await service.create(
      draft('Read', partial: const PartialConfig(reminderCount: 0, until: LocalTime(20, 0))),
    );
    // Nothing to undo yet.
    expect(await service.reopen(a.id, today), isFalse);

    await service.markTimeDone(a.id, today);
    await service.markTimeDone(a.id, today);
    await service.setProgress(p.id, today, 100);
    changes.clear();

    expect(await service.reopen(a.id, today), isTrue);
    final counter = (await occurrences.find(a.id, today))!;
    expect(counter.isOpen, isTrue);
    expect(counter.completedCount, 1); // only the last time is undone
    expect(counter.completedAt, isNull);
    expect(changes.single, {today});

    expect(await service.reopen(p.id, today), isTrue);
    final partial = (await occurrences.find(p.id, today))!;
    expect(partial.isOpen, isTrue);
    expect(partial.progress, 0);
  });

  test('past days cannot be reopened', () async {
    final a = await service.create(draft('Water'));
    await service.markTimeDone(a.id, today);
    clock.current = DateTime(2026, 9, 30, 8);
    expect(await service.reopen(a.id, today), isFalse);
    expect((await occurrences.find(a.id, today))!.isCompleted, isTrue);
  });

  test('day rollover turns yesterday into a missed, unresolved occurrence', () async {
    final a = await service.create(draft('Water'));
    clock.current = DateTime(2026, 9, 30, 8);
    await service.rollover();

    final missed = await occurrences.getUnresolvedMissed();
    expect(missed.single.activityId, a.id);
    expect(missed.single.date, today);
    // The new day has its own occurrence.
    expect(await occurrences.find(a.id, today.addDays(1)), isNotNull);

    // Running it again changes nothing.
    changes.clear();
    await service.rollover();
    expect(changes, isEmpty);
  });

  test('missed occurrences: complete retroactively, move, or leave', () async {
    final daily = await service.create(draft('Vitamins'));
    final weekly = await service.create(
      draft('Water plants', recurrence: const WeeklyRecurrence(weekday: DateTime.tuesday)),
    );
    final other = await service.create(
      draft('Call mom', recurrence: const WeeklyRecurrence(weekday: DateTime.tuesday)),
    );
    clock.current = DateTime(2026, 9, 30, 8);
    await service.rollover();

    Future<Occurrence> missedOf(Activity a) async => (await occurrences.find(a.id, today))!;

    // Daily: tomorrow already has it, so it cannot move; it can be ticked.
    final vitamins = await missedOf(daily);
    expect(await service.canMoveToNextDay(vitamins), isFalse);
    await service.completeRetroactively(vitamins.id);
    final ticked = await missedOf(daily);
    expect(ticked.isCompleted, isTrue);
    expect(ticked.retroactive, isTrue);

    // Weekly: today is free, so it moves with fresh progress.
    final plants = await missedOf(weekly);
    expect(await service.canMoveToNextDay(plants), isTrue);
    expect(await service.moveToNextDay(plants.id), isTrue);
    expect((await missedOf(weekly)).resolution, MissedResolution.moved);
    final copy = (await occurrences.find(weekly.id, today.addDays(1)))!;
    expect(copy.isOpen, isTrue);
    expect(copy.originalDate, today);
    // A second move of the same source is refused.
    expect(await service.moveToNextDay(plants.id), isFalse);

    // Leave it: resolved without completion.
    await service.leaveIncomplete((await missedOf(other)).id);
    expect(await occurrences.getUnresolvedMissed(), isEmpty);
  });

  test('retroactive completion of a moved occurrence removes the open copy', () async {
    final weekly = await service.create(
      draft('Water plants', recurrence: const WeeklyRecurrence(weekday: DateTime.tuesday)),
    );
    clock.current = DateTime(2026, 9, 30, 8);
    await service.rollover();
    final source = (await occurrences.find(weekly.id, today))!;
    await service.moveToNextDay(source.id);
    await service.completeRetroactively(source.id);
    final copy = (await occurrences.find(weekly.id, today.addDays(1)))!;
    expect(copy.status, OccurrenceStatus.skipped);
  });

  test('postponing today to tomorrow and skipping a day', () async {
    final weekly = await service.create(
      draft('Water', recurrence: const WeeklyRecurrence(weekday: DateTime.tuesday)),
    );
    final daily = await service.create(draft('Walk'));

    final water = (await occurrences.find(weekly.id, today))!;
    expect(service.moveTargetFor(water), today.addDays(1));
    expect(await service.moveToNextDay(water.id), isTrue);

    await service.skipDay(daily.id, today);
    expect((await occurrences.find(daily.id, today))!.status, OccurrenceStatus.skipped);
  });

  test('deleting the whole activity hides its open occurrences but keeps history', () async {
    final a = await service.create(draft('Water'));
    await service.markTimeDone(a.id, today);
    clock.current = DateTime(2026, 9, 30, 8);
    await service.rollover();

    await service.deleteActivity(a.id);
    expect(await activities.getAll(), isEmpty);
    expect((await activities.getById(a.id))!.isDeleted, isTrue);
    expect((await occurrences.find(a.id, today))!.isCompleted, isTrue);
    expect((await occurrences.find(a.id, today.addDays(1)))!.status, OccurrenceStatus.skipped);
  });

  test('partial progress feeds the goal and notifies once at 100%', () async {
    final goal = await goals.create(year: 2026, month: 9, title: 'Haircut', target: 100);
    final a = await service.create(
      draft(
        'Book the barber',
        partial: const PartialConfig(reminderCount: 1, until: LocalTime(20, 0)),
        goalLink: GoalLink(goalId: goal.id, impact: 100, type: ImpactType.additive),
      ),
    );
    await service.setProgress(a.id, today, 50);
    expect((await goals.progressOfMonth(2026, 9)).single.progress, 50);
    expect(notifier.reached, isEmpty);

    await service.setProgress(a.id, today, 100);
    expect((await goals.progressOfMonth(2026, 9)).single.progress, 100);
    expect(notifier.reached, ['Haircut']);

    // Already notified: no second notification.
    await goals.checkCompletions(2026, 9);
    expect(notifier.reached.length, 1);
  });

  test('settings persist as JSON in the key/value store', () async {
    final repo = StoredSettingsRepository(DriftKeyValueStore(db));
    expect((await repo.load()).needsLanguageChoice, isTrue);
    await repo.save(
      const AppSettings(
        localeCode: 'it',
        theme: ThemeConfig(presetId: 'night', cardColor: 0xFF112233),
      ),
    );
    final loaded = await repo.load();
    expect(loaded.localeCode, 'it');
    expect(loaded.theme.presetId, 'night');
    expect(loaded.theme.cardColor, 0xFF112233);
    expect(await repo.watch().first, isA<AppSettings>());
  });
}
