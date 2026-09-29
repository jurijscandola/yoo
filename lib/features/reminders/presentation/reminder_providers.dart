import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/stable_hash.dart';
import '../../../l10n/l10n.dart';
import '../../goals/domain/goal_service.dart';
import '../../goals/domain/monthly_goal.dart';
import '../../settings/presentation/settings_providers.dart';
import '../application/reminder_scheduler.dart';
import '../domain/reminder_gateway.dart';

/// The platform notification system. Does nothing by default (tests, and
/// before initialization); `main` overrides it with the real gateway.
final reminderGatewayProvider = Provider<ReminderGateway>((ref) => const NoopReminderGateway());

/// Strings in the user's language, readable without a [BuildContext]
/// (background isolates have none).
final reminderStringsProvider = Provider<Future<AppLocalizations> Function()>((ref) {
  return () async {
    final settings = await ref.read(settingsRepositoryProvider).load();
    return lookupAppLocalizations(Locale(settings.localeCode ?? 'en'));
  };
});

/// Notification action labels from the localized strings.
ReminderLabels reminderLabelsOf(AppLocalizations l10n) => ReminderLabels(
  done: l10n.notifDone,
  full: l10n.notifFull,
  half: l10n.notifHalf,
  other: l10n.notifOther,
  inputLabel: l10n.notifInputLabel,
);

/// The single scheduler of the app (it coalesces concurrent refreshes, so it
/// must not be recreated per call).
final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  final strings = ref.watch(reminderStringsProvider);
  return ReminderScheduler(
    activities: ref.watch(activityRepositoryProvider),
    occurrences: ref.watch(occurrenceRepositoryProvider),
    gateway: ref.watch(reminderGatewayProvider),
    clock: ref.watch(clockProvider),
    labels: () async => reminderLabelsOf(await strings()),
  );
});

/// Refreshes the reminder schedule. Failures are only logged: the data change
/// that triggered the refresh has already succeeded, and the next refresh
/// (resume, periodic task) retries.
Future<void> Function() reminderRefreshOf(Ref ref) {
  return () async {
    try {
      await ref.read(reminderSchedulerProvider).refresh();
    } catch (error, stack) {
      debugPrint('Reminder refresh failed: $error\n$stack');
    }
  };
}

/// Sends the "goal reached" notification through the reminder gateway.
class ReminderGoalNotifier implements GoalCompletionNotifier {
  ReminderGoalNotifier(this._gateway, this._strings);

  final ReminderGateway _gateway;
  final Future<AppLocalizations> Function() _strings;

  /// Notification id of the "goal reached" message of [goal]. Prefixed so it
  /// cannot collide with reminder ids in practice.
  static int idOf(MonthlyGoal goal) => stableHash('goal|${goal.id}');

  @override
  Future<void> notifyGoalReached(MonthlyGoal goal) async {
    final l10n = await _strings();
    await _gateway.showNow(
      id: idOf(goal),
      title: l10n.goalReachedTitle,
      body: l10n.goalReachedBody(goal.title),
    );
  }
}
