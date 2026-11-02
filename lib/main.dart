import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/background_tasks.dart';
import 'app/bootstrap.dart';
import 'features/reminders/data/local_notification_gateway.dart';
import 'features/settings/presentation/settings_providers.dart';

/// Entry point of Yoo: opens the local database, wires the persistent
/// implementations into the provider graph and sets up notifications.
Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keep the system splash screen (it shows the launcher icon) until the
  // settings are loaded, so the opening animation starts from the same logo
  // instead of the defaults.
  binding.deferFirstFrame();
  final gateway = LocalNotificationGateway();
  final container = openAppContainer(gateway);
  // Before the first refresh: scheduling needs the time zone database.
  await initializeReminders(
    container,
    gateway,
    onResponse: (response) => unawaited(handleNotificationResponse(container, response)),
  );
  followReminderSettings(container, gateway);
  followWidgetSettings(container);
  registerFontLicenses();
  await followLauncherIcon(container);
  runApp(UncontrolledProviderScope(container: container, child: const YooApp()));
  unawaited(_showFirstFrame(binding, container));
  unawaited(BackgroundTasks.register());
  unawaited(setUpHomeWidget(container));

  // An action pressed while the app was not running launched it. (The
  // reminder refresh of a normal start is done by the day watcher.)
  NotificationResponse? launch;
  try {
    launch = await gateway.launchResponse();
  } catch (_) {
    // Launch details are optional: a normal start follows.
  }
  if (launch != null) await handleNotificationResponse(container, launch);
}

/// Lets the first frame through once the settings are known (or after a
/// short wait, so the app never stays on the system splash).
Future<void> _showFirstFrame(WidgetsBinding binding, ProviderContainer container) async {
  try {
    await container.read(appSettingsProvider.future).timeout(const Duration(seconds: 2));
  } catch (_) {
    // Defaults are used: better than no app at all.
  }
  binding.allowFirstFrame();
}
