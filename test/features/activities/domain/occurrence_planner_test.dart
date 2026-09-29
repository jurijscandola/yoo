import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/core/time/local_time.dart';
import 'package:yoo/features/activities/domain/entities/activity.dart';
import 'package:yoo/features/activities/domain/entities/occurrence.dart';
import 'package:yoo/features/activities/domain/entities/recurrence.dart';
import 'package:yoo/features/activities/domain/services/occurrence_planner.dart';

import '../../../helpers/fixtures.dart';

void main() {
  const planner = OccurrencePlanner();
  final today = LocalDate(2026, 9, 29); // A Tuesday.
  final yesterday = today.addDays(-1);
  final tomorrow = today.addDays(1);

  group('missingOn', () {
    test('creates one occurrence per planned activity', () {
      final created = planner.missingOn(
        date: today,
        activities: [
          activity('daily'),
          activity('monday', recurrence: const WeeklyRecurrence(weekday: 1)),
        ],
        existingOnDate: const [],
        newId: sequentialIds(),
        now: testNow,
      );
      expect(created.map((o) => o.activityId), ['daily']);
      expect(created.single.date, today);
      expect(created.single.originalDate, today);
    });

    test('never duplicates an activity already present (e.g. moved there)', () {
      final created = planner.missingOn(
        date: today,
        activities: [activity('a')],
        existingOnDate: [occurrence('moved', 'a', today, originalDate: yesterday)],
        newId: sequentialIds(),
        now: testNow,
      );
      expect(created, isEmpty);
    });
  });

  group('rollover', () {
    test('marks past open occurrences as missed and unresolved', () {
      final result = planner.rollover(
        today: today,
        lastProcessed: yesterday,
        activities: [activity('a')],
        existing: [occurrence('y', 'a', yesterday)],
        newId: sequentialIds(),
        now: testNow,
      );
      final y = result.changed.firstWhere((o) => o.id == 'y');
      expect(y.status, OccurrenceStatus.missed);
      expect(y.resolution, MissedResolution.unresolved);
      // Today's occurrence is created too.
      expect(result.changed.where((o) => o.date == today).length, 1);
      expect(result.processedUntil, today);
    });

    test('leaves completed and skipped occurrences untouched', () {
      final result = planner.rollover(
        today: today,
        lastProcessed: yesterday,
        activities: [activity('a'), activity('b')],
        existing: [
          occurrence('done', 'a', yesterday, status: OccurrenceStatus.completed),
          occurrence('skip', 'b', yesterday, status: OccurrenceStatus.skipped),
        ],
        newId: sequentialIds(),
        now: testNow,
      );
      expect(result.changed.map((o) => o.id), isNot(contains('done')));
      expect(result.changed.map((o) => o.id), isNot(contains('skip')));
    });

    test('fills days the app was never opened on and asks only about the latest', () {
      final result = planner.rollover(
        today: today,
        lastProcessed: today.addDays(-3),
        activities: [activity('a')],
        existing: const [],
        newId: sequentialIds(),
        now: testNow,
      );
      final past = result.changed.where((o) => o.date.isBefore(today)).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      expect(past.map((o) => o.date), [today.addDays(-3), today.addDays(-2), yesterday]);
      expect(past.every((o) => o.status == OccurrenceStatus.missed), isTrue);
      expect(past.last.resolution, MissedResolution.unresolved);
      expect(past.take(2).every((o) => o.resolution == MissedResolution.leftIncomplete), isTrue);
    });

    test('is bounded by the catch-up window', () {
      const shortPlanner = OccurrencePlanner(maxCatchUpDays: 5);
      final result = shortPlanner.rollover(
        today: today,
        lastProcessed: LocalDate(2025, 1, 1),
        activities: [activity('a')],
        existing: const [],
        newId: sequentialIds(),
        now: testNow,
      );
      expect(result.changed.length, 6); // 5 past days + today.
    });

    test('is idempotent', () {
      final activities = [activity('a')];
      final first = planner.rollover(
        today: today,
        lastProcessed: yesterday,
        activities: activities,
        existing: const [],
        newId: sequentialIds(),
        now: testNow,
      );
      final second = planner.rollover(
        today: today,
        lastProcessed: today,
        activities: activities,
        existing: first.changed,
        newId: sequentialIds('other'),
        now: testNow,
      );
      expect(second.changed, isEmpty);
    });
  });

  group('moveToDay', () {
    final weekly = activity('water', recurrence: const WeeklyRecurrence(weekday: 1));

    test('moves a missed occurrence to a free day with fresh progress', () {
      final partial = activity(
        'p',
        recurrence: const WeeklyRecurrence(weekday: 1),
        partial: const PartialConfig(reminderCount: 2, until: LocalTime(21, 0)),
      );
      final source = occurrence(
        'y',
        'p',
        yesterday,
        status: OccurrenceStatus.missed,
        resolution: MissedResolution.unresolved,
        progress: 40,
      );
      final result = planner.moveToDay(
        activity: partial,
        source: source,
        target: today,
        storedOnTarget: const [],
        newId: sequentialIds(),
        now: testNow,
      )!;
      expect(result.original.status, OccurrenceStatus.missed);
      expect(result.original.resolution, MissedResolution.moved);
      expect(result.original.progress, 40); // Kept for summary and goals.
      expect(result.moved.date, today);
      expect(result.moved.originalDate, yesterday);
      expect(result.moved.progress, 0);
      expect(result.moved.isOpen, isTrue);
    });

    test('refuses when the target already has an occurrence by recurrence', () {
      final vitamins = activity('vitamins');
      final source = occurrence('y', 'vitamins', yesterday, status: OccurrenceStatus.missed);
      expect(
        planner.moveToDay(
          activity: vitamins,
          source: source,
          target: today,
          storedOnTarget: const [],
          newId: sequentialIds(),
          now: testNow,
        ),
        isNull,
      );
    });

    test('refuses when the target already holds a moved copy', () {
      final source = occurrence('t', 'water', today);
      expect(
        planner.moveToDay(
          activity: weekly,
          source: source,
          target: tomorrow,
          storedOnTarget: [occurrence('x', 'water', tomorrow)],
          newId: sequentialIds(),
          now: testNow,
        ),
        isNull,
      );
    });

    test('postpones an open occurrence of today to tomorrow', () {
      final result = planner.moveToDay(
        activity: weekly,
        source: occurrence('t', 'water', today),
        target: tomorrow,
        storedOnTarget: const [],
        newId: sequentialIds(),
        now: testNow,
      );
      expect(result, isNotNull);
      expect(result!.moved.date, tomorrow);
    });

    test('refuses completed sources and non-forward targets', () {
      final done = occurrence('t', 'water', today, status: OccurrenceStatus.completed);
      expect(
        planner.moveToDay(
          activity: weekly,
          source: done,
          target: tomorrow,
          storedOnTarget: const [],
          newId: sequentialIds(),
          now: testNow,
        ),
        isNull,
      );
      expect(
        planner.moveToDay(
          activity: weekly,
          source: occurrence('t', 'water', today),
          target: yesterday,
          storedOnTarget: const [],
          newId: sequentialIds(),
          now: testNow,
        ),
        isNull,
      );
    });
  });

  group('entriesOn', () {
    final activities = {
      'a': activity('a'),
      'b': activity('b', recurrence: const WeeklyRecurrence(weekday: 3)), // Wednesday.
    };

    test('future days mix stored copies and recurrence predictions', () {
      final entries = planner.entriesOn(
        date: tomorrow, // Wednesday.
        today: today,
        activitiesById: activities,
        storedOnDate: [occurrence('m', 'a', tomorrow, originalDate: today)],
      );
      expect(entries.length, 2);
      expect(entries.firstWhere((e) => e.activity.id == 'a').isPredicted, isFalse);
      expect(entries.firstWhere((e) => e.activity.id == 'b').isPredicted, isTrue);
    });

    test('past days show only stored occurrences, without skipped ones', () {
      final entries = planner.entriesOn(
        date: yesterday,
        today: today,
        activitiesById: activities,
        storedOnDate: [occurrence('s', 'a', yesterday, status: OccurrenceStatus.skipped)],
      );
      expect(entries, isEmpty);
    });
  });

  group('Occurrence completion', () {
    final triple = activity(
      't',
      slots: const [
        TimeSlot.at(LocalTime(8, 0)),
        TimeSlot.at(LocalTime(13, 0)),
        TimeSlot.at(LocalTime(20, 0)),
      ],
    );

    test('counter activities complete after every daily time', () {
      var o = occurrence('o', 't', today);
      o = o.markTimeDone(triple, testNow);
      expect(o.completedCount, 1);
      expect(o.isOpen, isTrue);
      expect(o.completionFor(triple), closeTo(1 / 3, 1e-9));
      o = o.markTimeDone(triple, testNow).markTimeDone(triple, testNow);
      expect(o.isCompleted, isTrue);
      expect(o.completionFor(triple), 1);
    });

    test('partial activities use the percentage', () {
      final partial = activity(
        'p',
        partial: const PartialConfig(reminderCount: 1, until: LocalTime(21, 0)),
      );
      final o = occurrence('o', 'p', today).withProgress(60, testNow);
      expect(o.isOpen, isTrue);
      expect(o.completionFor(partial), closeTo(0.6, 1e-9));
      expect(o.withProgress(100, testNow).isCompleted, isTrue);
    });

    test('retroactive completion resolves a missed occurrence', () {
      final o = occurrence(
        'o',
        't',
        yesterday,
        status: OccurrenceStatus.missed,
        resolution: MissedResolution.unresolved,
      ).completeRetroactively(triple, testNow);
      expect(o.isCompleted, isTrue);
      expect(o.retroactive, isTrue);
      expect(o.resolution, isNull);
      expect(o.completedCount, 3);
    });
  });
}
