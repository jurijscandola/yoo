import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/features/activities/domain/entities/occurrence.dart';
import 'package:yoo/features/activities/domain/services/occurrence_planner.dart';
import 'package:yoo/features/calendar/domain/day_mark.dart';

import '../../../helpers/fixtures.dart';

void main() {
  final today = LocalDate(2026, 9, 29);
  final yesterday = today.addDays(-1);

  DayEntry entry(String id, LocalDate date, [OccurrenceStatus? status]) => DayEntry(
    activity: activity(id),
    date: date,
    occurrence: status == null ? null : occurrence('o-$id', id, date, status: status),
  );

  test('empty days have no mark', () {
    expect(dayMarkOf(const [], today, today), DayMark.none);
  });

  test('future days are planned whatever is stored', () {
    final tomorrow = today.addDays(1);
    expect(dayMarkOf([entry('a', tomorrow)], tomorrow, today), DayMark.planned);
    expect(
      dayMarkOf([entry('a', tomorrow, OccurrenceStatus.completed)], tomorrow, today),
      DayMark.planned,
    );
  });

  test('all completed is done; any missed is missed', () {
    expect(
      dayMarkOf(
        [
          entry('a', yesterday, OccurrenceStatus.completed),
          entry('b', yesterday, OccurrenceStatus.completed),
        ],
        yesterday,
        today,
      ),
      DayMark.done,
    );
    expect(
      dayMarkOf(
        [
          entry('a', yesterday, OccurrenceStatus.completed),
          entry('b', yesterday, OccurrenceStatus.missed),
        ],
        yesterday,
        today,
      ),
      DayMark.missed,
    );
  });

  test('today with open activities is still planned', () {
    expect(
      dayMarkOf([entry('a', today, OccurrenceStatus.completed), entry('b', today)], today, today),
      DayMark.planned,
    );
  });
}
