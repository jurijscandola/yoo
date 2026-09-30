import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/time/local_date.dart';
import '../domain/entities/activity.dart';
import '../domain/entities/occurrence.dart';
import '../domain/entities/subtask.dart';
import '../domain/services/occurrence_planner.dart';

/// Every activity, deleted ones included (history needs them), by id.
final activitiesByIdProvider = StreamProvider<Map<String, Activity>>(
  (ref) => ref
      .watch(activityRepositoryProvider)
      .watchAll(includeDeleted: true)
      .map((list) => {for (final a in list) a.id: a}),
);

/// Stored occurrences of one day.
final occurrencesOnProvider = StreamProvider.autoDispose.family<List<Occurrence>, LocalDate>(
  (ref, date) => ref.watch(occurrenceRepositoryProvider).watchBetween(date, date),
);

/// Everything planned or stored on a day (see [OccurrencePlanner.entriesOn]).
final dayEntriesProvider = Provider.autoDispose.family<AsyncValue<List<DayEntry>>, LocalDate>((
  ref,
  date,
) {
  final activities = ref.watch(activitiesByIdProvider);
  final occurrences = ref.watch(occurrencesOnProvider(date));
  final today = ref.watch(todayProvider);
  if (activities.hasError) return AsyncError(activities.error!, activities.stackTrace!);
  if (occurrences.hasError) return AsyncError(occurrences.error!, occurrences.stackTrace!);
  final byId = activities.value;
  final stored = occurrences.value;
  if (byId == null || stored == null) return const AsyncLoading();
  return AsyncData(
    const OccurrencePlanner().entriesOn(
      date: date,
      today: today,
      activitiesById: byId,
      storedOnDate: stored,
    ),
  );
});

/// Missed occurrences waiting for the user's decision.
final unresolvedMissedProvider = StreamProvider<List<Occurrence>>(
  (ref) => ref.watch(occurrenceRepositoryProvider).watchUnresolvedMissed(),
);

/// Subtasks of an activity, in order.
final subtasksProvider = StreamProvider.autoDispose.family<List<Subtask>, String>(
  (ref, activityId) => ref.watch(subtaskRepositoryProvider).watchForActivity(activityId),
);

/// Ids of the subtasks of an activity checked on a day.
final checkedSubtasksProvider = StreamProvider.autoDispose.family<Set<String>, (String, LocalDate)>(
  (ref, key) {
    final (activityId, date) = key;
    return ref.watch(subtaskRepositoryProvider).watchChecked(activityId, date);
  },
);
