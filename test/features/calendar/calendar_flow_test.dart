import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/app/providers.dart';
import 'package:yoo/app/services.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/core/time/local_time.dart';
import 'package:yoo/features/activities/domain/entities/activity.dart';
import 'package:yoo/features/activities/domain/entities/activity_draft.dart';
import 'package:yoo/features/activities/domain/entities/occurrence.dart';
import 'package:yoo/features/activities/domain/entities/recurrence.dart';
import 'package:yoo/features/calendar/domain/day_mark.dart';
import 'package:yoo/features/calendar/presentation/calendar_providers.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';

import '../../helpers/fake_reminder_gateway.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

void main() {
  const english = AppSettings(localeCode: 'en');
  final today = LocalDate(2026, 9, 29);

  Future<void> openCalendar(WidgetTester tester, TestApp app) async {
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
  }

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));

  ActivityDraft draft(String name, {GoalLink? goalLink, LocalDate? start}) => ActivityDraft(
    name: name,
    notificationText: 'Time for $name',
    borderColorIndex: 0,
    recurrence: const DailyRecurrence(),
    timeSlots: const [TimeSlot.at(LocalTime(18, 0))],
    startDate: start ?? today,
    goalLink: goalLink,
  );

  testWidgets('shows the current month and navigates between months', (tester) async {
    await openCalendar(tester, TestApp(settings: english));

    expect(find.text('September 2026'), findsWidgets);
    expect(find.text('Mon'), findsOneWidget);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('Goals of October 2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('August 2026'), findsOneWidget);
    // Past months show their goals but cannot get new ones.
    expect(find.byTooltip('Add goal'), findsNothing);

    // The title brings back the current month.
    await tester.tap(find.text('August 2026'));
    await tester.pumpAndSettle();
    expect(find.text('September 2026'), findsOneWidget);
  });

  testWidgets('add, rename and delete a goal of the month', (tester) async {
    final app = TestApp(settings: english);
    await openCalendar(tester, app);
    expect(find.text('No goals for this month'), findsOneWidget);

    await tester.tap(find.byTooltip('Add goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Give the goal a name'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Read 4 books');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Read 4 books'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);

    await tester.tap(find.text('Read 4 books'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Read 5 books');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Read 5 books'), findsOneWidget);

    await tester.tap(find.text('Read 5 books'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete "Read 5 books"?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Read 5 books'), findsNothing);
    expect(find.text('No goals for this month'), findsOneWidget);
  });

  testWidgets('goal percentage follows linked activities and notifies at 100%', (tester) async {
    final gateway = FakeReminderGateway();
    final app = TestApp(settings: english, gateway: gateway);
    await openCalendar(tester, app);
    final container = containerOf(tester);

    final goal = await container
        .read(goalServiceProvider)
        .create(year: 2026, month: 9, title: 'Stay hydrated');
    final activities = container.read(activityServiceProvider);
    final water = await activities.create(
      draft(
        'Water',
        goalLink: GoalLink(goalId: goal.id, impact: 60, type: ImpactType.additive),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Stay hydrated'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);

    await activities.setProgress(water.id, today, 100);
    await tester.pumpAndSettle();
    expect(find.text('60%'), findsOneWidget);
    expect(gateway.shown, isEmpty);

    await activities.setProgress(water.id, today.addDays(1), 100);
    await tester.pumpAndSettle();
    expect(find.text('Reached'), findsOneWidget);
    expect(gateway.shown.single.title, 'Goal reached!');
    expect(gateway.shown.single.body, '"Stay hydrated" is at 100%');
  });

  testWidgets('tapping a day opens its summary with what is planned', (tester) async {
    final app = TestApp(settings: english);
    await openCalendar(tester, app);
    await containerOf(tester).read(activityServiceProvider).create(draft('Stretch'));
    await tester.pumpAndSettle();

    // The first "30" is 30 August, shown before the month starts.
    await tester.tap(find.text('30').last);
    await tester.pumpAndSettle();
    expect(find.text('Daily summary'), findsOneWidget);
    expect(find.text('Stretch'), findsOneWidget);
    expect(find.text('Planned'), findsOneWidget);
  });

  testWidgets('days are marked done, missed or planned', (tester) async {
    final app = TestApp(settings: english);
    await openCalendar(tester, app);
    final container = containerOf(tester);
    final a = activity('a', start: LocalDate(2026, 9, 27));
    await container.read(activityRepositoryProvider).save(a);
    await container.read(occurrenceRepositoryProvider).saveAll([
      occurrence('o1', 'a', LocalDate(2026, 9, 27), status: OccurrenceStatus.completed),
      occurrence('o2', 'a', LocalDate(2026, 9, 28), status: OccurrenceStatus.missed),
    ]);
    await tester.pumpAndSettle();

    final marks = container.read(monthMarksProvider((2026, 9))).value!;
    expect(marks[LocalDate(2026, 9, 26)], isNull);
    expect(marks[LocalDate(2026, 9, 27)], DayMark.done);
    expect(marks[LocalDate(2026, 9, 28)], DayMark.missed);
    expect(marks[today], DayMark.planned);
    expect(marks[LocalDate(2026, 9, 30)], DayMark.planned);
  });
}
