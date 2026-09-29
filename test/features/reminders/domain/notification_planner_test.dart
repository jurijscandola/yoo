import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/core/time/local_time.dart';
import 'package:yoo/features/activities/domain/entities/activity.dart';
import 'package:yoo/features/activities/domain/entities/occurrence.dart';
import 'package:yoo/features/activities/domain/entities/recurrence.dart';
import 'package:yoo/features/reminders/domain/notification_planner.dart';

import '../../../helpers/fixtures.dart';

void main() {
  const planner = NotificationPlanner(horizonDays: 3);
  final today = LocalDate(2026, 9, 29);
  final now = DateTime(2026, 9, 29, 10, 0);

  List<PlannedReminder> plan(List<Activity> activities, [List<Occurrence> stored = const []]) =>
      planner.plan(now: now, activities: activities, stored: stored);

  test('schedules only future reminders, earliest first', () {
    final a = activity(
      'a',
      slots: const [TimeSlot.at(LocalTime(9, 0)), TimeSlot.at(LocalTime(18, 0))],
    );
    final reminders = plan([a]);
    // Today 09:00 is past; today 18:00, then two per day for the next 2 days.
    expect(reminders.length, 5);
    expect(reminders.first.date, today);
    expect(reminders.first.time, const LocalTime(18, 0));
    for (var i = 1; i < reminders.length; i++) {
      expect(reminders[i].localDateTime.isAfter(reminders[i - 1].localDateTime), isTrue);
    }
  });

  test('random time stays inside the slot and is stable across runs', () {
    final a = activity(
      'a',
      slots: const [TimeSlot(from: LocalTime(14, 0), to: LocalTime(16, 30))],
    );
    final first = plan([a]);
    final second = plan([a]);
    expect(first.map((r) => r.localDateTime), second.map((r) => r.localDateTime));
    for (final r in first) {
      expect(r.time.inMinutes, inInclusiveRange(14 * 60, 16 * 60 + 30));
    }
    // Different days usually get different minutes.
    expect(first.map((r) => r.time).toSet().length, greaterThan(1));
  });

  test('ids are stable and unique per reminder', () {
    final a = activity(
      'a',
      slots: const [TimeSlot.at(LocalTime(12, 0)), TimeSlot.at(LocalTime(20, 0))],
    );
    final reminders = plan([a]);
    expect(reminders.map((r) => r.id).toSet().length, reminders.length);
    expect(plan([a]).map((r) => r.id), reminders.map((r) => r.id));
  });

  test('respects recurrences and skips deleted activities', () {
    final weekly = activity(
      'w',
      recurrence: const WeeklyRecurrence(weekday: 3),
      slots: const [TimeSlot.at(LocalTime(12, 0))],
    );
    final deleted = activity('d', deletedAt: testNow, slots: const [TimeSlot.at(LocalTime(12, 0))]);
    final reminders = plan([weekly, deleted]);
    expect(reminders.single.date, today.addDays(1)); // Wednesday.
  });

  test('completed or skipped occurrences get no reminders', () {
    final a = activity('a', slots: const [TimeSlot.at(LocalTime(12, 0))]);
    final reminders = plan(
      [a],
      [
        occurrence('t', 'a', today, status: OccurrenceStatus.completed),
        occurrence('m', 'a', today.addDays(1), status: OccurrenceStatus.skipped),
      ],
    );
    expect(reminders.single.date, today.addDays(2));
  });

  test('counter activities skip the times already done', () {
    final a = activity(
      'a',
      slots: const [
        TimeSlot.at(LocalTime(11, 0)),
        TimeSlot.at(LocalTime(15, 0)),
        TimeSlot.at(LocalTime(19, 0)),
      ],
    );
    final reminders = plan(
      [a],
      [occurrence('t', 'a', today, completedCount: 2)],
    ).where((r) => r.date == today);
    expect(reminders.map((r) => r.time), [const LocalTime(19, 0)]);
  });

  test('moved copies are reminded on days outside the recurrence', () {
    final weekly = activity(
      'w',
      recurrence: const WeeklyRecurrence(weekday: 1),
      slots: const [TimeSlot.at(LocalTime(12, 0))],
    );
    final reminders = plan(
      [weekly],
      [occurrence('m', 'w', today, originalDate: today.addDays(-1))],
    );
    expect(reminders.single.date, today);
  });

  group('partial activities', () {
    final partial = activity(
      'p',
      slots: const [TimeSlot.at(LocalTime(12, 0))],
      partial: const PartialConfig(reminderCount: 3, until: LocalTime(21, 0)),
    );

    test('follow-ups are spread evenly until the configured time', () {
      final todays = plan([partial]).where((r) => r.date == today).toList();
      expect(todays.map((r) => r.kind), [
        ReminderKind.slot,
        ReminderKind.followUp,
        ReminderKind.followUp,
        ReminderKind.followUp,
      ]);
      expect(todays.skip(1).map((r) => r.time), const [
        LocalTime(15, 0),
        LocalTime(18, 0),
        LocalTime(21, 0),
      ]);
      expect(todays.every((r) => r.isPartial), isTrue);
    });

    test('follow-ups stop once the activity reaches 100%', () {
      final done = occurrence('t', 'p', today).withProgress(100, testNow);
      expect(plan([partial], [done]).where((r) => r.date == today), isEmpty);
    });

    test('follow-ups continue while below 100%', () {
      final half = occurrence('t', 'p', today).withProgress(50, testNow);
      expect(plan([partial], [half]).where((r) => r.date == today).length, 4);
    });

    test('no follow-ups when the end time is before the last slot', () {
      expect(
        NotificationPlanner.followUpTimes(
          const LocalTime(22, 0),
          const PartialConfig(reminderCount: 2, until: LocalTime(21, 0)),
        ),
        isEmpty,
      );
    });
  });

  test('the window is capped to the maximum count', () {
    const capped = NotificationPlanner(horizonDays: 7, maxCount: 4);
    final activities = [
      for (var i = 0; i < 3; i++) activity('a$i', slots: const [TimeSlot.at(LocalTime(12, 0))]),
    ];
    expect(capped.plan(now: now, activities: activities, stored: const []).length, 4);
  });

  test('payload round-trips', () {
    final payload = ReminderPayload(activityId: 'abc', date: today);
    final decoded = ReminderPayload.tryDecode(payload.encode())!;
    expect(decoded.activityId, 'abc');
    expect(decoded.date, today);
    expect(ReminderPayload.tryDecode('goal|x'), isNull);
    expect(ReminderPayload.tryDecode(null), isNull);
  });
}
