import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/time/local_date.dart';
import '../../activities/domain/entities/occurrence.dart';
import '../../activities/domain/services/occurrence_planner.dart';
import '../../activities/presentation/activity_providers.dart';
import '../domain/day_mark.dart';

/// A calendar month.
typedef YearMonth = (int year, int month);

/// Stored occurrences of a whole month.
final monthOccurrencesProvider = StreamProvider.autoDispose.family<List<Occurrence>, YearMonth>((
  ref,
  month,
) {
  final first = LocalDate(month.$1, month.$2, 1);
  return ref.watch(occurrenceRepositoryProvider).watchBetween(first, first.lastOfMonth);
});

/// The mark of every day of a month (days without anything are left out).
final monthMarksProvider = Provider.autoDispose
    .family<AsyncValue<Map<LocalDate, DayMark>>, YearMonth>((ref, month) {
      final activities = ref.watch(activitiesByIdProvider);
      final occurrences = ref.watch(monthOccurrencesProvider(month));
      final today = ref.watch(todayProvider);
      if (activities.hasError) return AsyncError(activities.error!, activities.stackTrace!);
      if (occurrences.hasError) return AsyncError(occurrences.error!, occurrences.stackTrace!);
      final byId = activities.value;
      final stored = occurrences.value;
      if (byId == null || stored == null) return const AsyncLoading();

      const planner = OccurrencePlanner();
      final storedByDay = groupBy(stored, (Occurrence o) => o.date);
      final first = LocalDate(month.$1, month.$2, 1);
      final marks = <LocalDate, DayMark>{};
      for (final day in first.rangeTo(first.lastOfMonth)) {
        final entries = planner.entriesOn(
          date: day,
          today: today,
          activitiesById: byId,
          storedOnDate: storedByDay[day] ?? const [],
        );
        final mark = dayMarkOf(entries, day, today);
        if (mark != DayMark.none) marks[day] = mark;
      }
      return AsyncData(marks);
    });
