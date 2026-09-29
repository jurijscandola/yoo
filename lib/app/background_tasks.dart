import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import 'bootstrap.dart';
import 'services.dart';

/// Periodic background work: keeps the reminder window full and the day
/// rollover current even when the app is not opened for days.
abstract final class BackgroundTasks {
  /// Task id. On iOS it is also the BGTask identifier: it must match
  /// `BGTaskSchedulerPermittedIdentifiers` in Info.plist and the registration
  /// in AppDelegate.
  static const refresh = 'com.app.yoo.refresh';

  /// Registers the periodic task (about hourly; the OS decides the exact
  /// moment). Safe to call on every start: an existing task is kept.
  static Future<void> register() async {
    try {
      await Workmanager().initialize(backgroundTaskDispatcher);
      await Workmanager().registerPeriodicTask(
        refresh,
        refresh,
        frequency: const Duration(hours: 1),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      );
    } catch (error, stack) {
      debugPrint('Background task registration failed: $error\n$stack');
    }
  }
}

/// Entry point of the background tasks (runs in its own isolate).
@pragma('vm:entry-point')
void backgroundTaskDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await runInBackground((container) async {
        // The rollover's change hook checks goals and refreshes reminders;
        // the explicit refreshes cover days where nothing changed.
        await container.read(activityServiceProvider).rollover();
        await container.read(reminderRefreshProvider)();
        await container.read(homeWidgetRefreshProvider)();
      });
      return true;
    } catch (error, stack) {
      debugPrint('Background task $task failed: $error\n$stack');
      return false;
    }
  });
}
