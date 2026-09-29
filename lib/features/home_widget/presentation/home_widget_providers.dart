import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../application/home_widget_updater.dart';
import '../domain/home_screen_widget.dart';

/// The platform home screen widget. Does nothing by default (tests, iOS);
/// `main` overrides it with the Android one.
final homeScreenWidgetProvider = Provider<HomeScreenWidget>((ref) => const NoopHomeScreenWidget());

final homeWidgetUpdaterProvider = Provider<HomeWidgetUpdater>(
  (ref) => HomeWidgetUpdater(
    activities: ref.watch(activityRepositoryProvider),
    occurrences: ref.watch(occurrenceRepositoryProvider),
    settings: ref.watch(settingsRepositoryProvider),
    clock: ref.watch(clockProvider),
    widget: ref.watch(homeScreenWidgetProvider),
  ),
);

/// Refreshes the home screen widget. Failures are only logged: the data
/// change that triggered the refresh has already succeeded.
Future<void> Function() homeWidgetRefreshOf(Ref ref) {
  return () async {
    try {
      await ref.read(homeWidgetUpdaterProvider).update();
    } catch (error, stack) {
      debugPrint('Home widget refresh failed: $error\n$stack');
    }
  };
}
