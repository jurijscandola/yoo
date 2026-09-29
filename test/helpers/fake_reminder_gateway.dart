import 'dart:async';

import 'package:yoo/features/reminders/domain/notification_planner.dart';
import 'package:yoo/features/reminders/domain/reminder_gateway.dart';
import 'package:yoo/features/reminders/domain/reminder_permissions.dart';

/// In-memory notification system: records what is scheduled and shown.
class FakeReminderGateway implements ReminderGateway {
  /// Reminders currently scheduled, by id.
  final pending = <int, PlannedReminder>{};

  /// Labels used by the last [schedule] call.
  ReminderLabels? lastLabels;

  final cancelled = <int>[];
  final shown = <({int id, String title, String body})>[];
  int refreshRuns = 0;

  /// When set, [syncTimeZone] waits for it: lets tests overlap refreshes.
  Completer<void>? gate;

  @override
  Future<bool> syncTimeZone() async {
    refreshRuns++;
    await gate?.future;
    return false;
  }

  @override
  Future<Set<int>> pendingIds() async => pending.keys.toSet();

  @override
  Future<void> schedule(PlannedReminder reminder, ReminderLabels labels) async {
    lastLabels = labels;
    pending[reminder.id] = reminder;
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    pending.remove(id);
  }

  @override
  Future<void> showNow({required int id, required String title, required String body}) async {
    shown.add((id: id, title: title, body: body));
  }
}

/// Permissions whose answers tests control; records what was asked.
class FakeReminderPermissions implements ReminderPermissions {
  FakeReminderPermissions({this.notifications = false, this.exactAlarms = false});

  bool notifications;
  bool exactAlarms;

  /// What [requestNotifications] grants.
  bool grantOnRequest = true;

  final requests = <String>[];

  @override
  Future<bool> notificationsAllowed() async => notifications;

  @override
  Future<bool> requestNotifications() async {
    requests.add('notifications');
    notifications = grantOnRequest;
    return notifications;
  }

  @override
  Future<bool> exactAlarmsAllowed() async => exactAlarms;

  @override
  Future<void> requestExactAlarms() async {
    requests.add('exactAlarms');
    exactAlarms = true;
  }

  @override
  Future<void> openSystemSettings() async => requests.add('settings');
}
