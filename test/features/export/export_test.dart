import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/app/providers.dart';
import 'package:yoo/app/services.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/core/time/local_time.dart';
import 'package:yoo/features/activities/domain/entities/activity.dart';
import 'package:yoo/features/activities/domain/entities/occurrence.dart';
import 'package:yoo/features/export/application/month_text_formatter.dart';
import 'package:yoo/features/export/domain/export_destination.dart';
import 'package:yoo/features/export/domain/month_report.dart';
import 'package:yoo/features/goals/domain/goal_service.dart';
import 'package:yoo/features/goals/domain/monthly_goal.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';
import 'package:yoo/l10n/l10n.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

/// Records exported files.
class _RecordingDestination implements ExportDestination {
  final files = <(String, String)>[];

  @override
  Future<void> deliver({
    required String fileName,
    required String content,
    String? subject,
  }) async => files.add((fileName, content));
}

void main() {
  final today = LocalDate(2026, 9, 29);
  final vitamins = activity('v', start: LocalDate(2026, 9, 27));
  final reading = activity(
    'r',
    start: LocalDate(2026, 9, 28),
    partial: const PartialConfig(reminderCount: 0, until: LocalTime(20, 0)),
  );
  final goal = MonthlyGoal(
    id: 'g',
    year: 2026,
    month: 9,
    title: 'Read more',
    target: 100,
    createdAt: testNow,
    updatedAt: testNow,
  );

  MonthReport report() => MonthReport.build(
    year: 2026,
    month: 9,
    today: today,
    activitiesById: {'v': vitamins, 'r': reading},
    occurrences: [
      occurrence('1', 'v', LocalDate(2026, 9, 27), status: OccurrenceStatus.completed),
      occurrence('2', 'v', LocalDate(2026, 9, 28), status: OccurrenceStatus.missed),
      occurrence(
        '3',
        'r',
        LocalDate(2026, 9, 28),
        status: OccurrenceStatus.completed,
        progress: 100,
      ),
      occurrence('4', 'r', today, progress: 40),
    ],
    goals: [GoalProgress(goal, 62.4)],
  );

  test('the report covers the days up to today with their activities', () {
    final r = report();
    expect(r.days.map((d) => d.date.day), [27, 28, 29]);
    // Today: Vitamins is predicted (not stored yet), Reading is open.
    expect(r.days.last.entries.map((e) => e.activity.id), unorderedEquals(['v', 'r']));
    expect(r.completed, 2);
    expect(r.total, 5);
  });

  test('future months are empty', () {
    final r = MonthReport.build(
      year: 2026,
      month: 10,
      today: today,
      activitiesById: {'v': vitamins},
      occurrences: const [],
      goals: const [],
    );
    expect(r.isEmpty, isTrue);
  });

  test('the text lists goals, days and outcomes', () {
    final text = MonthTextFormatter(
      l10n: lookupAppLocalizations(const Locale('en')),
      monthLabel: 'September 2026',
      dayLabel: (d) => 'Day ${d.day}',
      exportedOn: '29 September 2026',
    ).format(report());

    expect(text, contains('\r\n'));
    final lines = text.split('\r\n');
    expect(lines.first, 'Yoo · September 2026');
    expect(lines, contains('Exported on 29 September 2026'));
    expect(lines, contains('  • Read more — 62 / 100'));
    expect(lines, containsAllInOrder(['Day 27', '  ✅ Activity v', 'Day 28']));
    expect(lines, contains('  ❌ Activity v'));
    expect(lines, contains('  ✅ Activity r — 100%'));
    expect(lines, contains('  ⏳ Activity r — 40%'));
    expect(lines, contains('Completed: 2 of 5'));
  });

  test('Italian text', () {
    final text = MonthTextFormatter(
      l10n: lookupAppLocalizations(const Locale('it')),
      monthLabel: 'settembre 2026',
      dayLabel: (d) => '${d.day}',
      exportedOn: '29 settembre 2026',
    ).format(report());
    expect(text, contains('OBIETTIVI'));
    expect(text, contains('Completate: 2 su 5'));
  });

  testWidgets('export screen previews the month and sends the file', (tester) async {
    final destination = _RecordingDestination();
    final app = TestApp(
      settings: const AppSettings(localeCode: 'en'),
      exportDestination: destination,
    );
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    await container.read(activityRepositoryProvider).save(vitamins);
    await container.read(goalServiceProvider).create(year: 2026, month: 9, title: 'Read more');

    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export data'));
    await tester.pumpAndSettle();

    expect(find.text('Preview'), findsOneWidget);
    expect(find.textContaining('• Read more — 0 / 1'), findsOneWidget);
    // The current month is the last one available.
    expect(
      tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_right)).onPressed,
      isNull,
    );

    await tester.tap(find.text('Export September 2026'));
    await tester.pumpAndSettle();
    final (name, content) = destination.files.single;
    expect(name, 'Yoo-2026-09.txt');
    expect(content, startsWith('Yoo · September 2026'));
    // The file has Windows line ends even though the preview does not.
    expect(content, contains('\r\n'));
    expect(content, contains('Activity v'));

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing recorded in this month'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Export August 2026'))
          .onPressed,
      isNull,
    );
  });
}
