import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/services.dart';
import '../domain/goal_service.dart';
import '../domain/monthly_goal.dart';

/// Goals that activities can still be linked to: this month and later ones.
final linkableGoalsProvider = StreamProvider<List<MonthlyGoal>>((ref) {
  final today = ref.watch(todayProvider);
  return ref
      .watch(goalRepositoryProvider)
      .watchAll()
      .map(
        (goals) => goals
            .where((g) => g.year > today.year || (g.year == today.year && g.month >= today.month))
            .toList(),
      );
});

/// Goals of a month with their live progress. Recomputed whenever goals,
/// activities or occurrences change.
final monthGoalsProgressProvider = StreamProvider.autoDispose
    .family<List<GoalProgress>, (int, int)>((ref, month) async* {
      final (year, m) = month;
      final service = ref.watch(goalServiceProvider);
      // Any change to the underlying tables triggers a recomputation.
      final changes = ref.watch(databaseProvider).tableUpdates();
      yield await service.progressOfMonth(year, m);
      await for (final _ in changes) {
        yield await service.progressOfMonth(year, m);
      }
    });
