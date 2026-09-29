import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/yoo_tokens.dart';
import '../data/in_memory_settings_repository.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// The settings repository. Overridden in `main` with the persistent one.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => InMemorySettingsRepository(),
);

/// Live user settings.
final appSettingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// Current settings, falling back to defaults while loading.
final currentSettingsProvider = Provider<AppSettings>(
  (ref) => ref.watch(appSettingsProvider).value ?? const AppSettings(),
);

/// Design tokens derived from the user's theme configuration.
final yooTokensProvider = Provider<YooTokens>(
  (ref) => YooTokens.fromConfig(ref.watch(currentSettingsProvider).theme),
);

/// Locale selected by the user (English until a choice is made).
final appLocaleProvider = Provider<Locale>(
  (ref) => Locale(ref.watch(currentSettingsProvider).localeCode ?? 'en'),
);

/// Write operations on the user's settings.
final settingsControllerProvider = Provider<SettingsController>(
  (ref) => SettingsController(ref.watch(settingsRepositoryProvider)),
);

/// Applies changes to [AppSettings] through the repository.
class SettingsController {
  SettingsController(this._repository);

  final SettingsRepository _repository;

  /// Stores the chosen UI language (`en`, `it`).
  Future<void> setLocale(String code) async {
    final current = await _repository.load();
    await _repository.save(current.copyWith(localeCode: code));
  }

  /// Stores the chosen app icon.
  Future<void> setAppIcon(String id) async {
    final current = await _repository.load();
    await _repository.save(current.copyWith(appIconId: id));
  }

  /// Replaces the external calendar preferences.
  Future<void> setExternalCalendars(ExternalCalendarSettings value) async {
    final current = await _repository.load();
    await _repository.save(current.copyWith(externalCalendars: value));
  }

  /// Replaces the theme configuration.
  Future<void> setTheme(ThemeConfig theme) async {
    final current = await _repository.load();
    await _repository.save(current.copyWith(theme: theme));
  }

  /// Applies [change] to the stored theme (read and written together, so
  /// quick successive changes never overwrite each other).
  Future<void> updateTheme(ThemeConfig Function(ThemeConfig theme) change) async {
    final current = await _repository.load();
    await _repository.save(current.copyWith(theme: change(current.theme)));
  }
}
