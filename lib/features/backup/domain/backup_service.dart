import '../../../core/time/clock.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/domain/settings_repository.dart';
import 'backup_file.dart';

/// Where the rows of a backup come from and go to (the local database).
abstract interface class BackupStore {
  /// Schema of the database the rows follow.
  int get schemaVersion;

  /// Every row of the user's tables, by table name.
  Future<Map<String, List<Map<String, Object?>>>> exportTables();

  /// Merges [backup] in: adds what is missing, replaces what is older, never
  /// deletes. All or nothing.
  Future<BackupImportResult> importTables(BackupFile backup);
}

/// Picks a file to import (the system file picker on Android).
abstract interface class BackupFileSource {
  bool get isSupported;

  /// The text of the file the user picked, or `null` if they cancelled.
  Future<String?> pickText();
}

/// Devices (and tests) without a file picker.
class UnsupportedBackupFileSource implements BackupFileSource {
  const UnsupportedBackupFileSource();

  @override
  bool get isSupported => false;

  @override
  Future<String?> pickText() async => null;
}

/// Full backups: everything needed to fill Yoo again on another phone or
/// after a reinstall.
///
/// The language and the appearance travel with the data; the app icon and
/// the device calendars do not (they belong to the device).
class BackupService {
  BackupService({
    required this._store,
    required this._settings,
    required this._clock,
    required this._afterImport,
  });

  final BackupStore _store;
  final SettingsRepository _settings;
  final Clock _clock;

  /// Brings the imported data up to today (day rollover, reminders, widget).
  final Future<void> Function() _afterImport;

  /// Name of a backup made now, e.g. `Yoo-backup-2026-11-02.json`.
  String fileName() => 'Yoo-backup-${_clock.today()}.json';

  /// The backup of everything, as the text of the file.
  Future<String> export() async {
    final settings = await _settings.load();
    return BackupFile(
      exportedAt: _clock.now(),
      schemaVersion: _store.schemaVersion,
      tables: await _store.exportTables(),
      settings: {'localeCode': settings.localeCode, 'theme': settings.theme.toJson()},
    ).encode();
  }

  /// Reads the text of a backup file; throws [BackupFormatException] if it is
  /// not one this version can import.
  BackupFile read(String text) => BackupFile.parse(text, currentSchema: _store.schemaVersion);

  /// Merges [backup] into the app (see [BackupStore.importTables]).
  Future<BackupImportResult> restore(BackupFile backup) async {
    final result = await _store.importTables(backup);
    final saved = backup.settings;
    if (saved != null) {
      final current = await _settings.load();
      final theme = saved['theme'];
      await _settings.save(
        current.copyWith(
          localeCode: saved['localeCode'] as String?,
          theme: theme is Map<String, Object?> ? ThemeConfig.fromJson(theme) : null,
        ),
      );
    }
    await _afterImport();
    return result;
  }
}
