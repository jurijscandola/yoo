import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/app/services.dart';
import 'package:yoo/core/database/app_database.dart';
import 'package:yoo/core/database/drift_key_value_store.dart';
import 'package:yoo/core/theme/yoo_palettes.dart';
import 'package:yoo/core/theme/yoo_tokens.dart';
import 'package:yoo/core/time/clock.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/core/time/local_time.dart';
import 'package:yoo/features/activities/data/drift_activity_repository.dart';
import 'package:yoo/features/activities/data/drift_occurrence_repository.dart';
import 'package:yoo/features/activities/domain/entities/activity.dart';
import 'package:yoo/features/activities/domain/entities/activity_draft.dart';
import 'package:yoo/features/activities/domain/entities/recurrence.dart';
import 'package:yoo/features/activities/domain/services/activity_service.dart';
import 'package:yoo/features/home_widget/application/home_widget_updater.dart';
import 'package:yoo/features/home_widget/domain/home_screen_widget.dart';
import 'package:yoo/features/home_widget/domain/widget_snapshot.dart';
import 'package:yoo/features/reminders/application/notification_action_handler.dart';
import 'package:yoo/features/reminders/domain/notification_planner.dart';
import 'package:yoo/features/reminders/domain/reminder_gateway.dart';
import 'package:yoo/features/settings/data/in_memory_settings_repository.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

/// Records what would be drawn.
class _FakeWidget implements HomeScreenWidget {
  final published = <(WidgetSnapshot, List<DateTime>)>[];

  WidgetSnapshot get last => published.last.$1;

  @override
  Future<void> publish(WidgetSnapshot snapshot, {required List<DateTime> redrawAt}) async =>
      published.add((snapshot, redrawAt));
}

void main() {
  final today = LocalDate(2026, 9, 29);

  group('links', () {
    test('a card link round-trips', () {
      final uri = WidgetLinks.complete(activityId: 'a b', date: today, action: 'done');
      expect(uri.toString(), startsWith('yoo://complete?'));
      final parsed = WidgetLinks.parseComplete(Uri.parse(uri.toString()))!;
      expect(parsed.activityId, 'a b');
      expect(parsed.date, today);
      expect(parsed.action, 'done');
    });

    test('other links are ignored', () {
      expect(WidgetLinks.parseComplete(WidgetLinks.home), isNull);
      expect(WidgetLinks.parseComplete(null), isNull);
      expect(
        WidgetLinks.parseComplete(Uri.parse('yoo://complete?activity=a&date=nope&action=done')),
        isNull,
      );
      expect(WidgetLinks.parseComplete(Uri.parse('https://complete?activity=a')), isNull);
    });
  });

  group('updater', () {
    late AppDatabase db;
    late _FakeWidget widget;
    late InMemorySettingsRepository settings;
    late ActivityService service;
    late HomeWidgetUpdater updater;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      widget = _FakeWidget();
      settings = InMemorySettingsRepository(
        const AppSettings(
          localeCode: 'en',
          theme: ThemeConfig(presetId: 'night', cardColor: 0xFF123456),
        ),
      );
      final clock = FixedClock(DateTime(2026, 9, 29, 10));
      final activities = DriftActivityRepository(db);
      final occurrences = DriftOccurrenceRepository(db);
      updater = HomeWidgetUpdater(
        activities: activities,
        occurrences: occurrences,
        settings: settings,
        clock: clock,
        widget: widget,
      );
      service = ActivityService(
        activities: activities,
        occurrences: occurrences,
        store: DriftKeyValueStore(db),
        clock: clock,
        newId: sequentialIds(),
      );
    });

    tearDown(() => db.close());

    Future<Activity> create(String name, {int times = 1, PartialConfig? partial, int color = 3}) =>
        service.create(
          ActivityDraft(
            name: name,
            notificationText: name,
            borderColorIndex: color,
            recurrence: const DailyRecurrence(),
            timeSlots: [for (var i = 0; i < times; i++) TimeSlot.at(LocalTime(12 + i, 0))],
            startDate: today,
            partial: partial,
          ),
        );

    test('today and tomorrow with the activities still to do, in the theme colors', () async {
      final water = await create('Water', times: 3, color: 8);
      await create(
        'Study',
        partial: const PartialConfig(reminderCount: 1, until: LocalTime(20, 0)),
      );
      final walk = await create('Walk');
      await service.markTimeDone(water.id, today);
      await service.markTimeDone(walk.id, today);

      await updater.update();
      final (snapshot, redrawAt) = widget.published.single;

      final tokens = YooTokens.fromConfig(
        const ThemeConfig(presetId: 'night', cardColor: 0xFF123456),
      );
      expect(snapshot.colors.card, 0xFF123456);
      expect(snapshot.colors.page, tokens.page.toARGB32());
      expect(snapshot.colors.accent, tokens.accent.toARGB32());

      final (todayDay, tomorrow) = (snapshot.days[0], snapshot.days[1]);
      expect(todayDay.date, today);
      expect(todayDay.title, 'Today');
      expect(todayDay.subtitle, 'Tuesday, September 29');
      // Walk is done: only Study and Water (1 of 3 done) are left.
      expect(todayDay.items.map((i) => i.name), ['Study', 'Water']);
      final waterItem = todayDay.items.last;
      expect(waterItem.detail, '1/3');
      expect(waterItem.action, ReminderActions.done);
      expect(waterItem.borderColor, YooPalettes.borderColor(8).toARGB32());
      expect(todayDay.items.first.action, ReminderActions.full);

      expect(tomorrow.date, today.addDays(1));
      expect(tomorrow.title, 'Today'); // shown once tomorrow has come
      expect(tomorrow.items, hasLength(3));

      expect(redrawAt.first, DateTime(2026, 9, 30, 0, 0, 1));
      expect(redrawAt.last, DateTime(2026, 10, 1, 0, 0, 1));
    });

    test('empty days say whether everything is done', () async {
      await updater.update();
      expect(widget.last.days.first.emptyText, 'Nothing planned for this day');

      final walk = await create('Walk');
      await service.markTimeDone(walk.id, today);
      await updater.update();
      expect(widget.last.days.first.items, isEmpty);
      expect(widget.last.days.first.emptyText, 'All done for today');
    });

    test('Italian texts', () async {
      await settings.save(const AppSettings(localeCode: 'it'));
      await updater.update();
      expect(widget.last.days.first.title, 'Oggi');
      expect(widget.last.days.first.subtitle, 'Martedì 29 settembre');
      expect(widget.last.staleText, 'Apri Yoo per aggiornare');
    });

    test('a card tap completes like the notification action', () async {
      final study = await create(
        'Study',
        partial: const PartialConfig(reminderCount: 0, until: LocalTime(20, 0)),
      );
      await updater.update();
      final item = widget.last.days.first.items.single;
      final link = WidgetLinks.parseComplete(
        WidgetLinks.complete(activityId: item.activityId, date: today, action: item.action),
      )!;
      final changed = await NotificationActionHandler(service).handle(
        actionId: link.action,
        payload: ReminderPayload(activityId: link.activityId, date: link.date).encode(),
      );
      expect(changed, isTrue);
      await updater.update();
      expect(widget.last.days.first.items.where((i) => i.activityId == study.id), isEmpty);
    });
  });

  testWidgets('the widget is refreshed when activities change', (tester) async {
    final widget = _FakeWidget();
    final app = TestApp(
      settings: const AppSettings(localeCode: 'en'),
      homeScreenWidget: widget,
    );
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    final before = widget.published.length;

    final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    await container
        .read(activityServiceProvider)
        .create(
          ActivityDraft(
            name: 'Stretch',
            notificationText: 'Stretch',
            borderColorIndex: 0,
            recurrence: const DailyRecurrence(),
            timeSlots: const [TimeSlot.at(LocalTime(18, 0))],
            startDate: today,
          ),
        );
    await tester.pumpAndSettle();
    expect(widget.published.length, greaterThan(before));
    expect(widget.last.days.first.items.single.name, 'Stretch');
  });
}
