import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/core/time/local_time.dart';
import 'package:yoo/features/activities/domain/entities/activity.dart';
import 'package:yoo/features/activities/domain/entities/occurrence.dart';
import 'package:yoo/features/goals/domain/goal_progress_calculator.dart';
import 'package:yoo/features/goals/domain/monthly_goal.dart';

import '../../../helpers/fixtures.dart';

void main() {
  const calculator = GoalProgressCalculator();
  final goal = MonthlyGoal(
    id: 'g',
    year: 2026,
    month: 9,
    title: 'Get a haircut',
    // Goals created before quantities existed keep 100 as target.
    target: 100,
    createdAt: testNow,
    updatedAt: testNow,
  );
  final sept = LocalDate(2026, 9, 10);

  GoalLink link(int impact, [ImpactType type = ImpactType.additive]) =>
      GoalLink(goalId: 'g', impact: impact, type: type);

  double progress(List<Activity> activities, List<Occurrence> occurrences) => calculator.progressOf(
    goal: goal,
    activitiesById: {for (final a in activities) a.id: a},
    occurrences: occurrences,
  );

  test('sums additive impacts of completed occurrences', () {
    final a = activity('a', goalLink: link(30));
    expect(
      progress(
        [a],
        [
          occurrence('1', 'a', sept, status: OccurrenceStatus.completed),
          occurrence('2', 'a', sept.addDays(1), status: OccurrenceStatus.completed),
        ],
      ),
      60,
    );
  });

  test('subtractive links lower the goal, never below zero', () {
    final plus = activity('plus', goalLink: link(50));
    final minus = activity('minus', goalLink: link(20, ImpactType.subtractive));
    final occurrences = [
      occurrence('1', 'plus', sept, status: OccurrenceStatus.completed),
      occurrence('2', 'minus', sept, status: OccurrenceStatus.completed),
    ];
    expect(progress([plus, minus], occurrences), 30);
    expect(progress([minus], [occurrences.last]), 0);
  });

  test('partial completion weighs the impact', () {
    final p = activity(
      'p',
      goalLink: link(40),
      partial: const PartialConfig(reminderCount: 1, until: LocalTime(21, 0)),
    );
    expect(progress([p], [occurrence('1', 'p', sept, progress: 50)]), 20);
  });

  test('counter activities weigh the times done', () {
    final c = activity(
      'c',
      goalLink: link(30),
      slots: const [TimeSlot.at(LocalTime(9, 0)), TimeSlot.at(LocalTime(18, 0))],
    );
    expect(progress([c], [occurrence('1', 'c', sept, completedCount: 1)]), 15);
  });

  test('is capped at 100', () {
    final a = activity('a', goalLink: link(80));
    expect(
      progress(
        [a],
        [
          occurrence('1', 'a', sept, status: OccurrenceStatus.completed),
          occurrence('2', 'a', sept.addDays(1), status: OccurrenceStatus.completed),
        ],
      ),
      100,
    );
  });

  test('counts whole amounts towards a small target', () {
    final books = goal.copyWith(target: 4);
    final a = activity('a', goalLink: link(1));
    final days = [for (var i = 0; i < 6; i++) sept.addDays(i)];
    double progressOf(int done) => calculator.progressOf(
      goal: books,
      activitiesById: {'a': a},
      occurrences: [
        for (final (i, d) in days.take(done).indexed)
          occurrence('$i', 'a', d, status: OccurrenceStatus.completed),
      ],
    );
    expect(progressOf(3), 3);
    expect(progressOf(6), 4);
    expect(calculator.shouldNotifyCompletion(books, progressOf(3)), isFalse);
    expect(calculator.shouldNotifyCompletion(books, progressOf(4)), isTrue);
  });

  test('ignores other months, other goals, skipped and unlinked occurrences', () {
    final linked = activity('a', goalLink: link(30));
    final other = activity(
      'b',
      goalLink: const GoalLink(goalId: 'x', impact: 30, type: ImpactType.additive),
    );
    final unlinked = activity('c');
    expect(
      progress(
        [linked, other, unlinked],
        [
          occurrence('1', 'a', LocalDate(2026, 10, 1), status: OccurrenceStatus.completed),
          occurrence('2', 'a', sept, status: OccurrenceStatus.skipped),
          occurrence('3', 'b', sept, status: OccurrenceStatus.completed),
          occurrence('4', 'c', sept, status: OccurrenceStatus.completed),
        ],
      ),
      0,
    );
  });

  test('deleted activities keep counting for their past occurrences', () {
    final a = activity('a', goalLink: link(25), deletedAt: testNow);
    expect(progress([a], [occurrence('1', 'a', sept, status: OccurrenceStatus.completed)]), 25);
  });

  test('completion is notified once', () {
    expect(calculator.shouldNotifyCompletion(goal, 100), isTrue);
    expect(calculator.shouldNotifyCompletion(goal, 99.9), isFalse);
    final notified = goal.copyWith(completionNotifiedAt: () => testNow);
    expect(calculator.shouldNotifyCompletion(notified, 100), isFalse);
  });
}
