import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/core/time/local_time.dart';

void main() {
  group('LocalDate', () {
    test('normalizes overflowing components', () {
      expect(LocalDate(2026, 1, 32), LocalDate(2026, 2, 1));
      expect(LocalDate(2026, 13, 1), LocalDate(2027, 1, 1));
    });

    test('adds days across months, years and DST changes', () {
      expect(LocalDate(2026, 12, 31).addDays(1), LocalDate(2027, 1, 1));
      // Europe DST ends on 2026-10-25: a naive local DateTime would drift.
      expect(LocalDate(2026, 10, 24).addDays(2), LocalDate(2026, 10, 26));
      expect(LocalDate(2026, 3, 1).addDays(-1), LocalDate(2026, 2, 28));
    });

    test('counts days and months between dates', () {
      expect(LocalDate(2026, 3, 28).daysUntil(LocalDate(2026, 4, 2)), 5);
      expect(LocalDate(2026, 4, 2).daysUntil(LocalDate(2026, 3, 28)), -5);
      expect(LocalDate(2026, 11, 15).monthsUntil(LocalDate(2027, 2, 1)), 3);
    });

    test('knows month lengths including leap years', () {
      expect(LocalDate(2028, 2, 1).daysInMonth, 29);
      expect(LocalDate(2026, 2, 1).daysInMonth, 28);
      expect(LocalDate(2026, 4, 10).lastOfMonth, LocalDate(2026, 4, 30));
    });

    test('round-trips through its ISO string', () {
      final d = LocalDate(2026, 9, 5);
      expect(d.toString(), '2026-09-05');
      expect(LocalDate.parse('2026-09-05'), d);
    });

    test('iterates inclusive ranges', () {
      final days = LocalDate(2026, 9, 29).rangeTo(LocalDate(2026, 10, 2)).toList();
      expect(days.length, 4);
      expect(days.last, LocalDate(2026, 10, 2));
    });
  });

  group('LocalTime', () {
    test('converts to and from minutes and strings', () {
      expect(const LocalTime(8, 30).inMinutes, 510);
      expect(LocalTime.fromMinutes(510), const LocalTime(8, 30));
      expect(LocalTime.parse('07:05'), const LocalTime(7, 5));
      expect(const LocalTime(7, 5).toString(), '07:05');
    });
  });
}
