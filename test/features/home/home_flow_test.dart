import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/features/activities/data/drift_occurrence_repository.dart';
import 'package:yoo/features/activities/domain/entities/occurrence.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';

import '../../helpers/test_app.dart';

void main() {
  const english = AppSettings(localeCode: 'en');

  Future<void> createActivity(WidgetTester tester, String name) async {
    await tester.tap(find.byTooltip('New activity'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'e.g. Take vitamins'), name);
    await tester.tap(find.text('Save').first);
    await tester.pumpAndSettle();
  }

  testWidgets('create an activity, complete it and see it in the summary', (tester) async {
    final app = TestApp(settings: english);
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();

    expect(find.text('Nothing planned for this day'), findsOneWidget);

    await createActivity(tester, 'Take vitamins');
    expect(find.text('Take vitamins'), findsOneWidget);

    // Complete it: the card animates away and Home shows "all done".
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Take vitamins'), findsNothing);
    expect(find.text('All done for today'), findsOneWidget);

    // The header opens the daily summary with a green check.
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.text('Daily summary'), findsOneWidget);
    expect(find.text('Take vitamins'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('a completion can be undone from the summary', (tester) async {
    final app = TestApp(settings: english);
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    await createActivity(tester, 'Take vitamins');
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();
    expect(find.text('All done for today'), findsOneWidget);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mark as not done'));
    await tester.pumpAndSettle();
    expect(find.text('Mark "Take vitamins" as not done?'), findsOneWidget);
    await tester.tap(find.text('Not done'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Take vitamins'), findsOneWidget);
    expect(find.text('All done for today'), findsNothing);
  });

  testWidgets('an unknown location lands on Home instead of an error page', (tester) async {
    await tester.pumpWidget(TestApp(settings: english).build());
    await tester.pumpAndSettle();
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    router.go('yoo://home/');
    await tester.pumpAndSettle();
    expect(find.textContaining('Page Not Found'), findsNothing);
    expect(find.text('Nothing planned for this day'), findsOneWidget);
  });

  testWidgets('swiping shows other days; future days are previews', (tester) async {
    final app = TestApp(settings: english);
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    await createActivity(tester, 'Walk');

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.text('Walk'), findsOneWidget);
    // No check button on future days.
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('the next day asks what to do with missed activities', (tester) async {
    final app = TestApp(settings: english, now: DateTime(2026, 9, 29, 10));
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    await createActivity(tester, 'Water the plants');

    // Next morning: restart the app.
    app.clock.current = DateTime(2026, 9, 30, 8);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();

    expect(find.text('What should we do?'), findsOneWidget);
    await tester.tap(find.text('I did it'));
    await tester.pumpAndSettle();

    // Resolved: the sheet closes and yesterday counts as done.
    expect(find.text('What should we do?'), findsNothing);
    final stored = await DriftOccurrenceRepository(
      app.database,
    ).getBetween(LocalDate(2026, 9, 29), LocalDate(2026, 9, 29));
    expect(stored.single.status, OccurrenceStatus.completed);
    expect(stored.single.retroactive, isTrue);
  });
}
