/// What the OS allows the reminders to do. Implemented by the notification
/// gateway on devices; faked in tests.
abstract interface class ReminderPermissions {
  /// Whether notifications may be shown.
  Future<bool> notificationsAllowed();

  /// Asks the notification permission; returns whether it is granted.
  Future<bool> requestNotifications();

  /// Whether reminders may fire at the exact minute (always true on iOS).
  Future<bool> exactAlarmsAllowed();

  /// Opens the system screen where exact alarms are allowed (Android).
  Future<void> requestExactAlarms();

  /// Opens the app page of the system settings (permissions, battery).
  Future<void> openSystemSettings();
}

/// Permissions that are always granted: tests and platforms without them.
class GrantedReminderPermissions implements ReminderPermissions {
  const GrantedReminderPermissions();

  @override
  Future<bool> notificationsAllowed() async => true;

  @override
  Future<bool> requestNotifications() async => true;

  @override
  Future<bool> exactAlarmsAllowed() async => true;

  @override
  Future<void> requestExactAlarms() async {}

  @override
  Future<void> openSystemSettings() async {}
}
