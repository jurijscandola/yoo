import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/time/local_date.dart';
import '../features/activities/domain/services/activity_service.dart';
import '../features/goals/domain/goal_service.dart';
import '../features/reminders/presentation/reminder_providers.dart';
import 'providers.dart';

/// Sends the "goal reached" notification.
final goalCompletionNotifierProvider = Provider<GoalCompletionNotifier?>(
  (ref) =>
      ReminderGoalNotifier(ref.watch(reminderGatewayProvider), ref.watch(reminderStringsProvider)),
);

/// Refreshes the notification schedule.
final reminderRefreshProvider = Provider<Future<void> Function()>(reminderRefreshOf);

final goalServiceProvider = Provider<GoalService>(
  (ref) => GoalService(
    goals: ref.watch(goalRepositoryProvider),
    activities: ref.watch(activityRepositoryProvider),
    occurrences: ref.watch(occurrenceRepositoryProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
    notifier: ref.watch(goalCompletionNotifierProvider),
  ),
);

/// What happens after any data change: goal checks for the affected months,
/// then a refresh of the reminder schedule.
final changeHookProvider = Provider<ChangeHook>((ref) {
  return (Set<LocalDate> days) async {
    final goals = ref.read(goalServiceProvider);
    final months = {for (final d in days) (d.year, d.month)};
    for (final (year, month) in months) {
      await goals.checkCompletions(year, month);
    }
    await ref.read(reminderRefreshProvider)();
  };
});

final activityServiceProvider = Provider<ActivityService>(
  (ref) => ActivityService(
    activities: ref.watch(activityRepositoryProvider),
    occurrences: ref.watch(occurrenceRepositoryProvider),
    store: ref.watch(keyValueStoreProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
    onChanged: ref.watch(changeHookProvider),
  ),
);
