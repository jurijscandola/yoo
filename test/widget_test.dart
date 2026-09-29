import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/app/app.dart';
import 'package:yoo/features/settings/data/in_memory_settings_repository.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';
import 'package:yoo/features/settings/presentation/settings_providers.dart';

void main() {
  Widget buildApp(InMemorySettingsRepository repo) => ProviderScope(
    overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
    child: const YooApp(),
  );

  testWidgets('first launch: splash, language prompt, localized shell', (tester) async {
    final repo = InMemorySettingsRepository();
    await tester.pumpWidget(buildApp(repo));

    // The opening animation is on screen first.
    expect(find.text('Yoo'), findsOneWidget);
    await tester.pumpAndSettle();

    // Then the language prompt; choosing Italian localizes the shell.
    expect(find.text('Choose your language'), findsOneWidget);
    await tester.tap(find.text('Italiano'));
    await tester.pumpAndSettle();

    expect(find.text('Choose your language'), findsNothing);
    expect(find.text('Calendario'), findsWidgets);
    expect((await repo.load()).localeCode, 'it');
  });

  testWidgets('returning user skips the prompt and can open settings', (tester) async {
    final repo = InMemorySettingsRepository(const AppSettings(localeCode: 'en'));
    await tester.pumpWidget(buildApp(repo));
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
