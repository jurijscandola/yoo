import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/services.dart';
import '../domain/goal_service.dart';
import '../domain/monthly_goal.dart';

/// Goals that activities can still be linked to: this month and later ones,
/// except those moved to another month (their copy is linkable instead).
final linkableGoalsProvider = StreamProvider<List<MonthlyGoal>>((ref) {
  final today = ref.watch(todayProvider);
  return ref
      .watch(goalRepositoryProvider)
      .watchAll()
      .map(
        (goals) => goals
            .where((g) => g.year > today.year || (g.year == today.year && g.month >= today.month))
            .where((g) => g.outcome != GoalOutcome.moved)
            .toList(),
      );
});

/// Goals of months already over, not reached, waiting for a decision.
final goalsToDecideProvider = StreamProvider.autoDispose<List<GoalProgress>>((ref) async* {
  ref.watch(todayProvider);
  final service = ref.watch(goalServiceProvider);
  // Past months change too (e.g. a missed day completed later).
  final changes = ref.watch(databaseProvider).tableUpdates();
  yield await service.toDecide();
  await for (final _ in changes) {
    yield await service.toDecide();
  }
});

/// A goal by id, deleted or not (e.g. the one a moved goal continues).
final goalByIdProvider = FutureProvider.autoDispose.family<MonthlyGoal?, String>(
  (ref, id) => ref.watch(goalRepositoryProvider).getById(id),
);

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
