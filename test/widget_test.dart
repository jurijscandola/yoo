import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/app/startup/startup_gate.dart';
import 'package:yoo/core/widgets/yoo_icon.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('first launch: splash, language prompt, localized shell', (tester) async {
    final app = TestApp();
    await tester.pumpWidget(app.build());

    // The opening animation is on screen first, covering it all, with the
    // icon in the middle (where the system splash shows it).
    expect(find.text('Yoo'), findsOneWidget);
    final screen = tester.getSize(find.byType(MaterialApp));
    expect(tester.getSize(find.byType(SplashOverlay)), screen);
    expect(tester.getCenter(find.byType(YooIcon)), screen.center(Offset.zero));
    await tester.pumpAndSettle();
    expect(find.byType(SplashOverlay), findsNothing);

    // Then the language prompt; choosing Italian localizes the shell.
    expect(find.text('Choose your language'), findsOneWidget);
    await tester.tap(find.text('Italiano'));
    await tester.pumpAndSettle();

    expect(find.text('Choose your language'), findsNothing);
    expect(find.text('Calendario'), findsWidgets);
    expect((await app.settings.load()).localeCode, 'it');
  });

  testWidgets('returning user skips the prompt and can open settings', (tester) async {
    final app = TestApp(settings: const AppSettings(localeCode: 'en'));
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();

    expect(find.text('Choose your language'), findsNothing);

    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Export data'), findsOneWidget);
  });
}
