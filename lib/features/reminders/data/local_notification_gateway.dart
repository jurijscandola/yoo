import 'dart:io' show Platform;
import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/notification_planner.dart';
import '../domain/reminder_gateway.dart';
import '../domain/reminder_permissions.dart';

/// Signature of the callback receiving notification taps and actions.
typedef NotificationResponseHandler = void Function(NotificationResponse response);

/// [ReminderGateway] and [ReminderPermissions] backed by
/// flutter_local_notifications.
///
/// Reliability notes:
/// - reminders are scheduled with `zonedSchedule` in the device time zone,
///   exact while idle when the user allows exact alarms (inexact otherwise);
/// - the plugin's boot receiver restores them after a reboot or app update;
/// - the time zone is re-read on every refresh, so a zone change reschedules
///   everything at the right local time.
class LocalNotificationGateway implements ReminderGateway, ReminderPermissions {
  LocalNotificationGateway({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  String? _zone;
  Color? _accent;
  ({String reminders, String remindersDescription, String goals, String goalsDescription})?
  _channelNames;

  static const _remindersChannel = 'yoo_reminders';
  static const _goalsChannel = 'yoo_goals';
  static const _categorySimple = 'yoo_simple';
  static const _categoryPartial = 'yoo_partial';

  /// Initializes time zones and the plugin, registering action categories.
  ///
  /// [onResponse] handles taps/actions while the app runs; [onBackground]
  /// must be a top-level `@pragma('vm:entry-point')` function.
  Future<void> initialize({
    required ReminderLabels labels,
    NotificationResponseHandler? onResponse,
    NotificationResponseHandler? onBackground,
  }) async {
    tzdata.initializeTimeZones();
    await syncTimeZone();

    final darwinActions = [
      DarwinNotificationCategory(
        _categorySimple,
        actions: [DarwinNotificationAction.plain(ReminderActions.done, labels.done)],
      ),
      DarwinNotificationCategory(
        _categoryPartial,
        actions: [
          DarwinNotificationAction.plain(ReminderActions.full, labels.full),
          DarwinNotificationAction.plain(ReminderActions.half, labels.half),
          DarwinNotificationAction.text(
            ReminderActions.input,
            labels.other,
            buttonTitle: labels.done,
            placeholder: labels.inputLabel,
          ),
        ],
      ),
    ];

    await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('ic_stat_yoo'),
        iOS: DarwinInitializationSettings(
          // Permissions are requested explicitly, after an explanation.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          notificationCategories: darwinActions,
        ),
      ),
      onDidReceiveNotificationResponse: onResponse,
      onDidReceiveBackgroundNotificationResponse: onBackground,
    );
  }

  /// Sets the notification accent color (Android) and channel names.
  void configure({
    Color? accent,
    required ({
      String reminders,
      String remindersDescription,
      String goals,
      String goalsDescription,
    })
    channels,
  }) {
    _accent = accent;
    _channelNames = channels;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

  // ---------------------------------------------------------------------------
  // ReminderPermissions
  // ---------------------------------------------------------------------------

  @override
  Future<bool> notificationsAllowed() async {
    if (Platform.isAndroid) return await _android?.areNotificationsEnabled() ?? false;
    final options = await _ios?.checkPermissions();
    return options?.isEnabled ?? false;
  }

  /// Asks the notification permission (Android 13+ dialog, iOS alert).
  @override
  Future<bool> requestNotifications() async {
    if (Platform.isAndroid) return await _android?.requestNotificationsPermission() ?? false;
    return await _ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
  }

  @override
  Future<bool> exactAlarmsAllowed() async {
    if (!Platform.isAndroid) return true;
    return await _android?.canScheduleExactNotifications() ?? false;
  }

  /// Opens the Android "Alarms & reminders" permission screen.
  @override
  Future<void> requestExactAlarms() async {
    if (Platform.isAndroid) await _android?.requestExactAlarmsPermission();
  }

  @override
  Future<void> openSystemSettings() => openAppSettings();

  /// Payload of the notification that launched the app, if any.
  Future<NotificationResponse?> launchResponse() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp == true ? details!.notificationResponse : null;
  }

  // ---------------------------------------------------------------------------
  // ReminderGateway
  // ---------------------------------------------------------------------------

  @override
  Future<bool> syncTimeZone() async {
    String zone;
    try {
      zone = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(zone));
    } catch (_) {
      // Unknown identifier: fall back to UTC rather than failing to schedule.
      zone = 'UTC';
      tz.setLocalLocation(tz.UTC);
    }
    final changed = _zone != null && _zone != zone;
    _zone = zone;
    return changed;
  }

  @override
  Future<Set<int>> pendingIds() async {
    final pending = await _plugin.pendingNotificationRequests();
    return {for (final p in pending) p.id};
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> schedule(PlannedReminder reminder, ReminderLabels labels) async {
    final local = reminder.localDateTime;
    final when = tz.TZDateTime(
      tz.local,
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
    );
    final mode = await exactAlarmsAllowed()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    await _plugin.zonedSchedule(
      id: reminder.id,
      title: reminder.title,
      body: reminder.body,
      scheduledDate: when,
      payload: reminder.payload,
      androidScheduleMode: mode,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _remindersChannel,
          _channelNames?.reminders ?? 'Reminders',
          channelDescription: _channelNames?.remindersDescription,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          color: _accent,
          actions: reminder.isPartial
              ? [
                  AndroidNotificationAction(ReminderActions.full, labels.full),
                  AndroidNotificationAction(ReminderActions.half, labels.half),
                  AndroidNotificationAction(
                    ReminderActions.input,
                    labels.other,
                    inputs: [
                      AndroidNotificationActionInput(
                        label: labels.inputLabel,
                        choices: const ['25', '75'],
                      ),
                    ],
                  ),
                ]
              : [AndroidNotificationAction(ReminderActions.done, labels.done)],
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: reminder.isPartial ? _categoryPartial : _categorySimple,
          threadIdentifier: reminder.activityId,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
    );
  }

  @override
  Future<void> showNow({required int id, required String title, required String body}) {
    return _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _goalsChannel,
          _channelNames?.goals ?? 'Goals',
          channelDescription: _channelNames?.goalsDescription,
          importance: Importance.high,
          priority: Priority.high,
          color: _accent,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
