import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/app/services.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/core/time/local_time.dart';
import 'package:yoo/core/widgets/goals_bag_icon.dart';
import 'package:yoo/features/activities/domain/entities/activity.dart';
import 'package:yoo/features/activities/domain/entities/activity_draft.dart';
import 'package:yoo/features/activities/domain/entities/recurrence.dart';
import 'package:yoo/features/external_calendars/domain/external_calendar_source.dart';
import 'package:yoo/features/home/presentation/widgets/day_header.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';

import '../helpers/fake_external_calendars.dart';
import '../helpers/fake_reminder_gateway.dart';
import '../helpers/test_app.dart';

/// Every main screen on a small phone with the largest common text size:
/// any overflow fails the test.
void main() {
  for (final locale in ['en', 'it']) {
    testWidgets('main screens fit a small phone with 2x text ($locale)', (tester) async {
      tester.view.physicalSize = const Size(360, 690) * 3;
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);

      final app = TestApp(
        settings: AppSettings(
          localeCode: locale,
          externalCalendars: const ExternalCalendarSettings(enabled: true),
        ),
        permissions: FakeReminderPermissions(),
        externalCalendars: FakeExternalCalendarSource(
          calendars: const [ExternalCalendar(id: 'w', name: 'Work calendar with a long name')],
          events: [
            ExternalEvent(
              id: 'e',
              calendarId: 'w',
              title: 'Quarterly planning meeting with the whole extended team',
              start: DateTime(2026, 9, 29, 15),
              end: DateTime(2026, 9, 29, 16, 30),
              isAllDay: false,
            ),
          ],
        ),
      );
      await tester.pumpWidget(app.build());
      await tester.pumpAndSettle();

      // Permission prompt.
      expect(find.byType(FilledButton), findsOneWidget);
      await tester.ensureVisible(find.byType(TextButton).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextButton).last);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
      final goal = await container
          .read(goalServiceProvider)
          .create(year: 2026, month: 9, title: 'Read four long books before the end of the month');
      final activities = container.read(activityServiceProvider);
      for (final (i, name) in [
        'Take the vitamins after breakfast every single day',
        'Walk',
      ].indexed) {
        await activities.create(
          ActivityDraft(
            name: name,
            notificationText: name,
            borderColorIndex: i,
            recurrence: const DailyRecurrence(),
            timeSlots: const [TimeSlot.at(LocalTime(18, 0)), TimeSlot.at(LocalTime(20, 0))],
            startDate: LocalDate(2026, 9, 29),
            partial: i == 1 ? const PartialConfig(reminderCount: 2, until: LocalTime(22, 0)) : null,
            goalLink: GoalLink(goalId: goal.id, impact: 30, type: ImpactType.additive),
          ),
        );
      }
      await tester.pumpAndSettle();

      Future<void> open(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      Future<void> back() async {
        // pageBack() looks for the English "Back" tooltip.
        await tester.tap(find.byType(BackButton).last);
        await tester.pumpAndSettle();
      }

      // Home, its calendar sheet and the daily summary.
      await open(find.byIcon(Icons.expand_more));
      await tester.tapAt(const Offset(5, 5)); // close the sheet
      await tester.pumpAndSettle();
      await open(find.byType(DayHeader));
      await back();

      // Activity form.
      await open(find.byType(FloatingActionButton));
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -3000));
      await tester.pumpAndSettle();
      await back();

      // Calendar with goals, and a goal dialog.
      await open(find.byIcon(Icons.calendar_month_outlined));
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
      await tester.pumpAndSettle();
      await open(find.textContaining('Read four long books'));
      await tester.tapAt(const Offset(5, 5)); // dismiss the dialog
      await tester.pumpAndSettle();

      // Settings and its pages.
      await open(find.byType(GoalsBagIcon));
      await open(find.byIcon(Icons.more_horiz));
      for (final icon in [
        Icons.file_download_outlined,
        Icons.palette_outlined,
        Icons.event_outlined,
      ]) {
        await open(find.byIcon(icon));
        await tester.drag(find.byType(Scrollable).last, const Offset(0, -4000));
        await tester.pumpAndSettle();
        await back();
      }
    });
  }
}
