import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../core/database/app_database.dart';
import '../core/theme/yoo_fonts.dart';
import '../core/theme/yoo_tokens.dart';
import '../features/export/data/share_export_destination.dart';
import '../features/export/presentation/export_providers.dart';
import '../features/external_calendars/data/device_external_calendar_source.dart';
import '../features/external_calendars/presentation/external_calendar_providers.dart';
import '../features/home_widget/data/android_home_screen_widget.dart';
import '../features/home_widget/domain/widget_snapshot.dart';
import '../features/home_widget/presentation/home_widget_providers.dart';
import '../features/reminders/application/notification_action_handler.dart';
import '../features/reminders/data/local_notification_gateway.dart';
import '../features/reminders/domain/notification_planner.dart';
import '../features/reminders/presentation/reminder_providers.dart';
import '../features/settings/data/stored_settings_repository.dart';
import '../features/settings/presentation/settings_providers.dart';
import '../l10n/l10n.dart';
import 'providers.dart';
import 'router.dart';
import 'routes.dart';
import 'services.dart';

// Startup shared by the UI isolate (`main`) and the background isolates that
// handle notification actions and periodic work while the app is closed.

/// Opens the shared database and builds the provider graph with the
/// persistent implementations and the real notification gateway.
ProviderContainer openAppContainer(LocalNotificationGateway gateway) {
  return ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(AppDatabase.open()),
      settingsRepositoryProvider.overrideWith(
        (ref) => StoredSettingsRepository(ref.watch(keyValueStoreProvider)),
      ),
      reminderGatewayProvider.overrideWithValue(gateway),
      reminderPermissionsProvider.overrideWithValue(gateway),
      externalCalendarSourceProvider.overrideWithValue(DeviceExternalCalendarSource()),
      exportDestinationProvider.overrideWithValue(const ShareExportDestination()),
      homeScreenWidgetProvider.overrideWithValue(const AndroidHomeScreenWidget()),
    ],
  );
}

/// Initializes [gateway] with the user's language and colors.
///
/// Failures are logged and swallowed: the app must start even when the
/// notification system is unavailable; refreshes will then fail and log too.
Future<void> initializeReminders(
  ProviderContainer container,
  LocalNotificationGateway gateway, {
  NotificationResponseHandler? onResponse,
}) async {
  try {
    final l10n = await configureReminders(container, gateway);
    await gateway.initialize(
      labels: reminderLabelsOf(l10n),
      onResponse: onResponse,
      onBackground: onBackgroundNotificationResponse,
    );
  } catch (error, stack) {
    debugPrint('Notification setup failed: $error\n$stack');
  }
}

/// Applies the user's language (channel names) and notification color to
/// [gateway]; returns the strings used. Called at startup and whenever the
/// language or the color changes.
Future<AppLocalizations> configureReminders(
  ProviderContainer container,
  LocalNotificationGateway gateway,
) async {
  final settings = await container.read(settingsRepositoryProvider).load();
  final l10n = lookupAppLocalizations(Locale(settings.localeCode ?? 'en'));
  gateway.configure(
    accent: YooTokens.fromConfig(settings.theme).notification,
    channels: (
      reminders: l10n.channelReminders,
      remindersDescription: l10n.channelRemindersDescription,
      goals: l10n.channelGoals,
      goalsDescription: l10n.channelGoalsDescription,
    ),
  );
  return l10n;
}

/// Keeps scheduled reminders in line with the settings: a new language or
/// notification color reschedules them (same ids, so they are replaced).
void followReminderSettings(ProviderContainer container, LocalNotificationGateway gateway) {
  container.listen(
    currentSettingsProvider.select(
      (s) => (s.localeCode, YooTokens.fromConfig(s.theme).notification),
    ),
    (previous, next) async {
      if (previous == null || previous == next) return;
      try {
        await configureReminders(container, gateway);
      } catch (error, stack) {
        debugPrint('Notification setup failed: $error\n$stack');
      }
      await container.read(reminderRefreshProvider)();
    },
  );
}

/// Keeps the home screen widget in line with the theme and the language.
void followWidgetSettings(ProviderContainer container) {
  container.listen(
    currentSettingsProvider.select((s) => (s.localeCode, jsonEncode(s.theme.toJson()))),
    (previous, next) {
      if (previous != null && previous != next) container.read(homeWidgetRefreshProvider)();
    },
  );
}

/// Android home screen widget: registers the card tap callback and opens
/// Home when the widget header launched or resumed the app.
Future<void> setUpHomeWidget(ProviderContainer container) async {
  if (!Platform.isAndroid) return;
  try {
    await HomeWidget.registerInteractivityCallback(onHomeWidgetInteraction);
    HomeWidget.widgetClicked.listen((uri) {
      if (uri?.host == WidgetLinks.home.host) container.read(routerProvider).go(Routes.home);
    });
  } catch (error, stack) {
    debugPrint('Home widget setup failed: $error\n$stack');
  }
}

/// Entry point of taps on a home screen widget card (background isolate):
/// completes the activity with the same logic as a notification action.
@pragma('vm:entry-point')
Future<void> onHomeWidgetInteraction(Uri? uri) async {
  final target = WidgetLinks.parseComplete(uri);
  if (target == null) return;
  await runInBackground((container) async {
    try {
      await NotificationActionHandler(container.read(activityServiceProvider)).handle(
        actionId: target.action,
        payload: ReminderPayload(activityId: target.activityId, date: target.date).encode(),
      );
    } catch (error, stack) {
      debugPrint('Widget action failed: $error\n$stack');
    }
    // The change hook refreshed it already, unless nothing changed.
    await container.read(homeWidgetRefreshProvider)();
  });
}

/// Registers the licenses of the bundled fonts in the license page.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final MapEntry(key: family, value: path) in YooFonts.licenses.entries) {
      yield LicenseEntryWithLineBreaks([family], await rootBundle.loadString(path));
    }
  });
}

/// Applies a notification action (if any), then refreshes the reminders so
/// the follow-ups of a completed occurrence disappear.
Future<void> handleNotificationResponse(
  ProviderContainer container,
  NotificationResponse response,
) async {
  try {
    await NotificationActionHandler(
      container.read(activityServiceProvider),
    ).handle(actionId: response.actionId, payload: response.payload, input: response.input);
  } catch (error, stack) {
    debugPrint('Notification action failed: $error\n$stack');
  }
  await container.read(reminderRefreshProvider)();
}

/// Entry point of notification actions pressed while the app is not in the
/// foreground. Runs in a background isolate with its own provider graph on
/// the shared database.
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationResponse(NotificationResponse response) =>
    runInBackground((container) => handleNotificationResponse(container, response));

/// Runs [body] in a background isolate with a temporary provider graph on the
/// shared database and an initialized notification gateway.
Future<T> runInBackground<T>(Future<T> Function(ProviderContainer container) body) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final gateway = LocalNotificationGateway();
  final container = openAppContainer(gateway);
  try {
    await initializeReminders(container, gateway);
    return await body(container);
  } finally {
    final database = container.read(databaseProvider);
    container.dispose();
    await database.close();
  }
}
