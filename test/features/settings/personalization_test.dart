import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/core/database/app_database.dart';
import 'package:yoo/core/database/drift_key_value_store.dart';
import 'package:yoo/core/theme/yoo_palettes.dart';
import 'package:yoo/core/theme/yoo_tokens.dart';
import 'package:yoo/features/settings/data/stored_settings_repository.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';
import 'package:yoo/features/settings/presentation/personalization_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  const english = AppSettings(localeCode: 'en');

  test('theme config edits one thing at a time', () {
    const base = ThemeConfig(presetId: 'mist', fontFamily: 'Lora', pageColor: 1);
    final colored = base.withColor(ThemeColorSlot.cards, 0xFF123456);
    expect(colored.cardColor, 0xFF123456);
    expect(colored.pageColor, 1);
    expect(colored.fontFamily, 'Lora');
    expect(colored.withColor(ThemeColorSlot.cards, null).cardColor, isNull);
    expect(colored.withFont(null).fontFamily, isNull);
    expect(colored.withFont(null).cardColor, 0xFF123456);

    // A new preset drops the colors chosen for the old one, keeps the font.
    final night = colored.withPreset('night');
    expect(night.presetId, 'night');
    expect(night.cardColor, isNull);
    expect(night.fontFamily, 'Lora');

    for (final slot in ThemeColorSlot.values) {
      expect(base.withColor(slot, 42).colorOf(slot), 42);
    }
  });

  test('tokens follow the overrides; notifications default to the accent', () {
    final tokens = YooTokens.fromConfig(
      const ThemeConfig(presetId: 'mist', cardColor: 0xFF000001, notificationColor: null),
    );
    expect(tokens.card, const Color(0xFF000001));
    expect(tokens.notification, tokens.accent);
    expect(tokens.page, YooPalettes.presetById('mist').page);
  });

  test('theme and app icon survive persistence', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = StoredSettingsRepository(DriftKeyValueStore(db));
    expect((await repository.load()).appIconId, 'classic');
    await repository.save(
      const AppSettings(
        appIconId: 'ocean',
        theme: ThemeConfig(presetId: 'ink', textColor: 7, fontFamily: 'Nunito'),
      ),
    );
    final loaded = await repository.load();
    expect(loaded.appIconId, 'ocean');
    expect(loaded.theme.presetId, 'ink');
    expect(loaded.theme.textColor, 7);
    expect(loaded.theme.fontFamily, 'Nunito');
  });

  Future<void> openPersonalization(WidgetTester tester, TestApp app) async {
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personalization'));
    await tester.pumpAndSettle();
  }

  // Rows may not be built yet (lazy list) or be built but off-screen.
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        150,
        scrollable: find
            .descendant(of: find.byType(PersonalizationScreen), matching: find.byType(Scrollable))
            .first,
      );
    }
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  YooTokens tokensOf(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(Scaffold).last)).extension<YooTokens>()!;

  testWidgets('presets, colors and fonts apply immediately and are stored', (tester) async {
    final app = TestApp(settings: english);
    await openPersonalization(tester, app);
    expect(find.text('Morning walk'), findsOneWidget); // live preview

    await tester.tap(find.bySemanticsLabel('Night'));
    await tester.pumpAndSettle();
    expect((await app.settings.load()).theme.presetId, 'night');
    expect(tokensOf(tester).brightness, Brightness.dark);

    await scrollTo(tester, find.text('Cards'));
    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();
    final swatch = YooPalettes.backgroundSwatches.first;
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints?.maxWidth == 40 &&
            (w.decoration as BoxDecoration?)?.color == swatch,
      ),
    );
    await tester.pumpAndSettle();
    expect((await app.settings.load()).theme.cardColor, swatch.toARGB32());
    expect(tokensOf(tester).card, swatch);

    // "Default" goes back to the preset color.
    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Default'));
    await tester.pumpAndSettle();
    expect((await app.settings.load()).theme.cardColor, isNull);

    await scrollTo(tester, find.text('Lora'));
    await tester.tap(find.text('Lora'));
    await tester.pumpAndSettle();
    expect((await app.settings.load()).theme.fontFamily, 'Lora');
    expect(tokensOf(tester).fontFamily, 'Lora');

    await scrollTo(tester, find.text('Reset to default'));
    await tester.tap(find.text('Reset to default'));
    await tester.pumpAndSettle();
    final reset = (await app.settings.load()).theme;
    expect(reset.presetId, 'paper');
    expect(reset.fontFamily, isNull);
  });

  testWidgets('the app icon screen stores the chosen preview', (tester) async {
    final app = TestApp(settings: english);
    await openPersonalization(tester, app);
    await scrollTo(tester, find.text('Classic'));
    await tester.tap(find.text('Classic'));
    await tester.pumpAndSettle();

    expect(find.text('The final icons are on their way: these are previews.'), findsOneWidget);
    await tester.ensureVisible(find.text('Ocean'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ocean'));
    await tester.pumpAndSettle();
    expect((await app.settings.load()).appIconId, 'ocean');

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Ocean'), findsOneWidget);
  });
}
