import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';
import 'package:yoo/features/settings/presentation/settings_screen.dart';

import '../helpers/test_app.dart';

void main() {
  const english = AppSettings(localeCode: 'en');

  testWidgets('calendar days are announced with their full date', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(TestApp(settings: english).build());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    // table_calendar labels each cell (and hides what is inside it).
    expect(find.bySemanticsLabel('Monday, September 28, 2026'), findsOneWidget);
    expect(find.byTooltip('Previous month'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('settings open the license page', (tester) async {
    await tester.pumpWidget(TestApp(settings: english).build());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('About Yoo'),
      200,
      scrollable: find
          .descendant(of: find.byType(SettingsScreen), matching: find.byType(Scrollable))
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('About Yoo'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(LicensePage), findsOneWidget);
  });
}
