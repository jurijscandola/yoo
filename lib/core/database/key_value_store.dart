/// Small persistent key/value store for app state that is not a domain entity
/// (serialized settings, last processed day, notification bookkeeping).
abstract interface class KeyValueStore {
  Future<String?> read(String key);
  Stream<String?> watch(String key);
  Future<void> write(String key, String? value);
}

/// Keys used with [KeyValueStore], kept in one place to avoid clashes.
abstract final class StoreKeys {
  static const settings = 'settings';
  static const lastProcessedDate = 'lastProcessedDate';
  static const scheduledReminderIds = 'scheduledReminderIds';
  static const lastTimeZone = 'lastTimeZone';

  /// Set once the first-run permission prompt has been shown.
  static const permissionsAsked = 'permissionsAsked';
}
