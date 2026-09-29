import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/features/activities/domain/entities/recurrence.dart';

import '../../../helpers/fixtures.dart';

void main() {
  List<int> daysIn(Recurrence r, int year, int month) {
    final first = LocalDate(year, month, 1);
    return [
      for (final d in first.rangeTo(first.lastOfMonth))
        if (r.occursOn(d)) d.day,
    ];
  }

  test('daily occurs every day', () {
    expect(daysIn(const DailyRecurrence(), 2026, 2).length, 28);
  });

  test('every other day alternates from the anchor, also backwards', () {
    final r = EveryOtherDayRecurrence(anchor: LocalDate(2026, 9, 29));
    expect(r.occursOn(LocalDate(2026, 9, 29)), isTrue);
    expect(r.occursOn(LocalDate(2026, 9, 30)), isFalse);
    expect(r.occursOn(LocalDate(2026, 10, 1)), isTrue);
    // Parity holds across month boundaries and DST changes.
    expect(r.occursOn(LocalDate(2026, 10, 27)), isTrue);
    expect(r.occursOn(LocalDate(2026, 9, 27)), isTrue);
  });

  test('weekly occurs on the chosen weekday', () {
    const r = WeeklyRecurrence(weekday: DateTime.tuesday);
    expect(daysIn(r, 2026, 9), [1, 8, 15, 22, 29]);
  });

  test('monthly clamps to the last day of short months', () {
    const r = MonthlyRecurrence(day: 31);
    expect(daysIn(r, 2026, 1), [31]);
    expect(daysIn(r, 2026, 2), [28]);
    expect(daysIn(r, 2028, 2), [29]);
    expect(daysIn(r, 2026, 4), [30]);
    expect(daysIn(const MonthlyRecurrence(day: 15), 2026, 4), [15]);
  });

  group('specific days of the month', () {
    SpecificDaysRecurrence build(MonthRepeat repeat) => SpecificDaysRecurrence(
      days: const {1, 15, 31},
      repeat: repeat,
      anchorYear: 2026,
      anchorMonth: 11,
    );

    test('without repetition only the anchor month counts', () {
      final r = build(MonthRepeat.none);
      expect(daysIn(r, 2026, 10), isEmpty);
      expect(daysIn(r, 2026, 11), [1, 15]); // November has no 31st.
      expect(daysIn(r, 2026, 12), isEmpty);
    });

    test('next month repeats exactly once', () {
      final r = build(MonthRepeat.nextMonth);
      expect(daysIn(r, 2026, 12), [1, 15, 31]);
      expect(daysIn(r, 2027, 1), isEmpty);
    });

    test('every month repeats from the anchor onwards', () {
      final r = build(MonthRepeat.everyMonth);
      expect(daysIn(r, 2026, 10), isEmpty);
      expect(daysIn(r, 2027, 1), [1, 15, 31]);
      expect(daysIn(r, 2027, 2), [1, 15]);
    });
  });

  test('every recurrence survives a JSON round trip', () {
    final all = <Recurrence>[
      const DailyRecurrence(),
      EveryOtherDayRecurrence(anchor: LocalDate(2026, 9, 29)),
      const WeeklyRecurrence(weekday: 3),
      const MonthlyRecurrence(day: 12),
      const SpecificDaysRecurrence(
        days: {3, 9},
        repeat: MonthRepeat.everyMonth,
        anchorYear: 2026,
        anchorMonth: 9,
      ),
    ];
    for (final r in all) {
      expect(Recurrence.fromJson(r.toJson()), r);
    }
  });

  test('an activity is never planned before its start date or once deleted', () {
    final a = activity('a', start: LocalDate(2026, 9, 29));
    expect(a.isPlannedOn(LocalDate(2026, 9, 28)), isFalse);
    expect(a.isPlannedOn(LocalDate(2026, 9, 29)), isTrue);
    final deleted = activity('b', deletedAt: testNow);
    expect(deleted.isPlannedOn(LocalDate(2026, 9, 29)), isFalse);
  });
}
