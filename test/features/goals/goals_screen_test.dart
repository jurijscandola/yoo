import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/app/services.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/features/goals/data/drift_goal_repository.dart';
import 'package:yoo/features/goals/domain/monthly_goal.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';

import '../../helpers/test_app.dart';

void main() {
  const english = AppSettings(localeCode: 'en');

  Future<ProviderContainer> start(WidgetTester tester, TestApp app) async {
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
  }

  Future<void> openMonthlyGoals(WidgetTester tester) async {
    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monthly goals'));
    await tester.pumpAndSettle();
  }

  testWidgets('a goal of last month can be moved and starts again from zero', (tester) async {
    final app = TestApp(settings: english, now: DateTime(2026, 10, 2, 9));
    final container = await start(tester, app);
    await container
        .read(goalServiceProvider)
        .create(year: 2026, month: 9, title: 'Read 4 books', target: 4);
    await tester.pumpAndSettle();

    // The tab shows a dot while something waits for a decision.
    expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);

    // The Goals tab says how many wait, and opens the monthly goals.
    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();
    expect(find.text('1 goal to decide'), findsOneWidget);
    await tester.tap(find.text('Monthly goals'));
    await tester.pumpAndSettle();

    // One month at a time, starting from this one; the banner opens the
    // goals to decide.
    expect(find.text('October 2026'), findsOneWidget);
    await tester.tap(find.text('1 goal to decide'));
    await tester.pumpAndSettle();
    expect(find.text('To decide'), findsOneWidget);
    await tester.tap(find.text('Move to October 2026'));
    await tester.pumpAndSettle();
    // All decided: the sheet and the banner go away.
    expect(find.text('To decide'), findsNothing);
    expect(find.text('1 goal to decide'), findsNothing);
    expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);

    // October has the copy, from zero.
    expect(find.text('0 / 4'), findsOneWidget);
    expect(find.textContaining('Continued from September 2026'), findsOneWidget);

    // September, one month back, shows where it went.
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('September 2026'), findsOneWidget);
    // (On the card, and in the message of the move, still on screen.)
    expect(find.textContaining('Moved to October 2026'), findsNWidgets(2));
    // Tapping the month comes back to this one.
    await tester.tap(find.text('September 2026'));
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);

    final stored = await DriftGoalRepository(app.database).getAll();
    expect(
      stored.map((g) => (g.month, g.outcome)),
      unorderedEquals([(9, GoalOutcome.moved), (10, null)]),
    );
  });

  testWidgets('a goal of this month can be marked as completed and reopened', (tester) async {
    final app = TestApp(settings: english);
    final container = await start(tester, app);
    await container.read(goalServiceProvider).create(year: 2026, month: 9, title: 'Dentist');
    await openMonthlyGoals(tester);
    expect(find.text('0 of 1 reached'), findsOneWidget);

    await tester.tap(find.text('Dentist'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark as completed'));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('1 of 1 reached'), findsOneWidget);

    await tester.tap(find.text('Dentist'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reopen'));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsNothing);
    expect(find.text('0 / 1'), findsOneWidget);
  });

  testWidgets('a goal of last month can also be added to this month, per day', (tester) async {
    final app = TestApp(settings: english, now: DateTime(2026, 11, 2, 9));
    final container = await start(tester, app);
    final service = container.read(goalServiceProvider);
    await service.create(year: 2026, month: 10, title: 'Take creatine', target: 31);
    await openMonthlyGoals(tester);

    // From the goals to decide, a goal opens all its actions.
    await tester.tap(find.text('1 goal to decide'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take creatine'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Also add to November 2026'));
    await tester.pumpAndSettle();
    // Proposed with the days of November; it can still be changed.
    expect(find.widgetWithText(TextField, 'Take creatine'), findsOneWidget);
    expect(find.widgetWithText(TextField, '30'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Added to November 2026'), findsOneWidget);

    final november = await service.progressOfMonth(2026, 11);
    expect(november.map((p) => (p.goal.title, p.goal.target)), [('Take creatine', 30)]);
    // October stays as it was, still waiting for a decision.
    final october = (await service.progressOfMonth(2026, 10)).single;
    expect(october.goal.outcome, isNull);
    expect(october.needsDecisionAt(LocalDate(2026, 11, 2)), isTrue);
  });
}
