import 'dart:convert';

import '../../../core/database/key_value_store.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// [SettingsRepository] persisted as JSON in the [KeyValueStore].
class StoredSettingsRepository implements SettingsRepository {
  StoredSettingsRepository(this._store);

  final KeyValueStore _store;

  static AppSettings _decode(String? raw) {
    if (raw == null) return const AppSettings();
    final json = jsonDecode(raw) as Map<String, Object?>;
    return AppSettings(
      localeCode: json['localeCode'] as String?,
      theme: json['theme'] == null
          ? const ThemeConfig()
          : ThemeConfig.fromJson(json['theme']! as Map<String, Object?>),
      externalCalendars: json['externalCalendars'] == null
          ? const ExternalCalendarSettings()
          : ExternalCalendarSettings.fromJson(json['externalCalendars']! as Map<String, Object?>),
      appIconId: json['appIconId'] as String? ?? AppSettings.defaultAppIconId,
    );
  }

  static String _encode(AppSettings s) => jsonEncode({
    'localeCode': s.localeCode,
    'theme': s.theme.toJson(),
    'externalCalendars': s.externalCalendars.toJson(),
    'appIconId': s.appIconId,
  });

  @override
  Stream<AppSettings> watch() => _store.watch(StoreKeys.settings).map(_decode);

  @override
  Future<AppSettings> load() async => _decode(await _store.read(StoreKeys.settings));

  @override
  Future<void> save(AppSettings settings) => _store.write(StoreKeys.settings, _encode(settings));
}
