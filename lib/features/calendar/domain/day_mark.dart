import '../../../core/time/local_date.dart';
import '../../activities/domain/entities/occurrence.dart';
import '../../activities/domain/services/occurrence_planner.dart';

/// What the calendar shows under a day.
enum DayMark {
  /// Nothing planned.
  none,

  /// Something is planned or still open.
  planned,

  /// Everything completed.
  done,

  /// At least one activity was not completed.
  missed,
}

/// Summarizes the entries of [date] (see [OccurrencePlanner.entriesOn], which
/// already leaves out skipped occurrences) for the calendar.
DayMark dayMarkOf(List<DayEntry> entries, LocalDate date, LocalDate today) {
  if (entries.isEmpty) return DayMark.none;
  if (date.isAfter(today)) return DayMark.planned;
  final statuses = entries.map((e) => e.occurrence?.status);
  if (statuses.every((s) => s == OccurrenceStatus.completed)) return DayMark.done;
  if (statuses.any((s) => s == OccurrenceStatus.missed)) return DayMark.missed;
  return DayMark.planned;
}
