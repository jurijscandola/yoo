import 'app_settings.dart';

/// Abstract access to the user's preferences.
///
/// The local implementation stores them on the device; a future sync layer can
/// provide an implementation that also mirrors them to the user's account.
abstract interface class SettingsRepository {
  /// Emits the current settings immediately and then every change.
  Stream<AppSettings> watch();

  /// Returns the current settings once.
  Future<AppSettings> load();

  /// Persists [settings], replacing the previous value.
  Future<void> save(AppSettings settings);
}
