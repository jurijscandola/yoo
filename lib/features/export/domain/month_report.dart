import 'package:collection/collection.dart';

import '../../../core/time/local_date.dart';
import '../../activities/domain/entities/activity.dart';
import '../../activities/domain/entities/occurrence.dart';
import '../../activities/domain/services/occurrence_planner.dart';
import '../../goals/domain/goal_service.dart';

/// What happened in a month: goals with their progress and, for every day up
/// to today, the activities with their outcome.
class MonthReport {
  const MonthReport({
    required this.year,
    required this.month,
    required this.goals,
    required this.days,
  });

  final int year;
  final int month;
  final List<GoalProgress> goals;

  /// Days with at least one activity, in order. Future days are left out.
  final List<ReportDay> days;

  /// Activities of the month (one per day and activity) and how many were
  /// completed.
  int get total => days.fold(0, (sum, d) => sum + d.entries.length);
  int get completed => days.fold(
    0,
    (sum, d) =>
        sum + d.entries.where((e) => e.occurrence?.status == OccurrenceStatus.completed).length,
  );

  bool get isEmpty => goals.isEmpty && days.isEmpty;

  /// Builds the report of [year]/[month] from the stored data.
  factory MonthReport.build({
    required int year,
    required int month,
    required LocalDate today,
    required Map<String, Activity> activitiesById,
    required Iterable<Occurrence> occurrences,
    required List<GoalProgress> goals,
  }) {
    const planner = OccurrencePlanner();
    final first = LocalDate(year, month, 1);
    final last = first.lastOfMonth.isAfter(today) ? today : first.lastOfMonth;
    final byDay = groupBy(occurrences, (Occurrence o) => o.date);
    final days = <ReportDay>[];
    for (final day in first.rangeTo(last)) {
      final entries = planner.entriesOn(
        date: day,
        today: today,
        activitiesById: activitiesById,
        storedOnDate: byDay[day] ?? const [],
      );
      if (entries.isNotEmpty) days.add(ReportDay(day, entries));
    }
    return MonthReport(year: year, month: month, goals: goals, days: days);
  }
}

/// One day of a [MonthReport].
class ReportDay {
  const ReportDay(this.date, this.entries);

  final LocalDate date;
  final List<DayEntry> entries;
}
