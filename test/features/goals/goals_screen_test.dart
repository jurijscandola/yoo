import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/app/services.dart';
import 'package:yoo/features/goals/data/drift_goal_repository.dart';
import 'package:yoo/features/goals/domain/monthly_goal.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';

import '../../helpers/test_app.dart';

void main() {
  const english = AppSettings(localeCode: 'en');

  Future<ProviderContainer> openGoals(WidgetTester tester, TestApp app) async {
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    return container;
  }

  Future<void> tapGoalsTab(WidgetTester tester) async {
    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();
  }

  testWidgets('a goal of last month can be moved and starts again from zero', (tester) async {
    final app = TestApp(settings: english, now: DateTime(2026, 10, 2, 9));
    final container = await openGoals(tester, app);
    await container
        .read(goalServiceProvider)
        .create(year: 2026, month: 9, title: 'Read 4 books', target: 4);
    await tester.pumpAndSettle();

    // The tab shows a dot while something waits for a decision.
    final badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isTrue);

    await tapGoalsTab(tester);
    expect(find.text('To decide'), findsOneWidget);
    expect(find.text('Read 4 books'), findsWidgets);

    await tester.tap(find.text('Move to October 2026'));
    await tester.pumpAndSettle();
    expect(find.text('To decide'), findsNothing);
    expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);

    // October has the copy, from zero; September shows where it went.
    // (Both read 0 / 4: the copy, and September as it was left.)
    expect(find.text('0 / 4'), findsNWidgets(2));
    expect(find.textContaining('Continued from September 2026'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Past months'), 200);
    expect(find.textContaining('Moved to October 2026'), findsWidgets);

    final stored = await DriftGoalRepository(app.database).getAll();
    expect(
      stored.map((g) => (g.month, g.outcome)),
      unorderedEquals([(9, GoalOutcome.moved), (10, null)]),
    );
  });

  testWidgets('a goal of this month can be marked as completed and reopened', (tester) async {
    final app = TestApp(settings: english);
    final container = await openGoals(tester, app);
    await container.read(goalServiceProvider).create(year: 2026, month: 9, title: 'Dentist');
    await tapGoalsTab(tester);

    await tester.tap(find.text('Dentist'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark as completed'));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);

    await tester.tap(find.text('Dentist'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reopen'));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsNothing);
    expect(find.text('0 / 1'), findsOneWidget);
  });
}
