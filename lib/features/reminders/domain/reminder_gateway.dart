import 'notification_planner.dart';

/// Identifiers of the actions offered by reminder notifications.
abstract final class ReminderActions {
  /// Counter activities: one more time done.
  static const done = 'done';

  /// Partial activities: set to 100%.
  static const full = 'p100';

  /// Partial activities: set to 50%.
  static const half = 'p50';

  /// Partial activities: free percentage typed in the notification.
  static const input = 'pinput';

  /// Parses the percentage typed in a notification ("40", "40%", " 40 ").
  static int? parsePercent(String? raw) {
    final digits = raw?.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits == null || digits.isEmpty) return null;
    return int.parse(digits).clamp(0, 100);
  }
}

/// Localized labels used when building notifications.
class ReminderLabels {
  const ReminderLabels({
    required this.done,
    required this.full,
    required this.half,
    required this.other,
    required this.inputLabel,
  });

  final String done;
  final String full;
  final String half;
  final String other;
  final String inputLabel;
}

/// Platform notification system, as seen by the reminder logic. Implemented
/// with flutter_local_notifications; faked in tests.
abstract interface class ReminderGateway {
  /// Ids of the reminders currently scheduled on the device.
  Future<Set<int>> pendingIds();

  /// Schedules (or replaces, same id) [reminder].
  Future<void> schedule(PlannedReminder reminder, ReminderLabels labels);

  /// Cancels the reminder with [id].
  Future<void> cancel(int id);

  /// Shows a notification immediately.
  Future<void> showNow({required int id, required String title, required String body});

  /// Re-reads the device time zone; returns true when it changed.
  Future<bool> syncTimeZone();
}

/// Gateway that does nothing: used by tests and before initialization.
class NoopReminderGateway implements ReminderGateway {
  const NoopReminderGateway();

  @override
  Future<Set<int>> pendingIds() async => const {};

  @override
  Future<void> schedule(PlannedReminder reminder, ReminderLabels labels) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> showNow({required int id, required String title, required String body}) async {}

  @override
  Future<bool> syncTimeZone() async => false;
}
