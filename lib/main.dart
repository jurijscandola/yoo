import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'app/services.dart';
import 'features/reminders/data/local_notification_gateway.dart';

/// Entry point of Yoo: opens the local database, wires the persistent
/// implementations into the provider graph and sets up notifications.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final gateway = LocalNotificationGateway();
  final container = openAppContainer(gateway);
  // Before the first refresh: scheduling needs the time zone database.
  await initializeReminders(
    container,
    gateway,
    onResponse: (response) => unawaited(handleNotificationResponse(container, response)),
  );
  runApp(UncontrolledProviderScope(container: container, child: const YooApp()));

  // An action pressed while the app was not running launched it.
  NotificationResponse? launch;
  try {
    launch = await gateway.launchResponse();
  } catch (_) {
    // Launch details are optional: a normal start follows.
  }
  if (launch != null) {
    await handleNotificationResponse(container, launch);
  } else {
    await container.read(reminderRefreshProvider)();
  }
}
