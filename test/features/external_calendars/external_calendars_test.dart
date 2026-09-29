import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/app/providers.dart';
import 'package:yoo/core/database/app_database.dart';
import 'package:yoo/core/database/drift_key_value_store.dart';
import 'package:yoo/core/time/local_time.dart';
import 'package:yoo/features/activities/domain/entities/activity.dart';
import 'package:yoo/features/external_calendars/domain/external_calendar_source.dart';
import 'package:yoo/features/external_calendars/presentation/external_calendar_providers.dart';
import 'package:yoo/features/settings/data/stored_settings_repository.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';

import '../../helpers/fake_external_calendars.dart';
import '../../helpers/test_app.dart';

void main() {
  const work = ExternalCalendar(id: 'work', name: 'Work', account: 'me@work.com');
  const family = ExternalCalendar(id: 'family', name: 'Family');

  ExternalEvent event(
    String title,
    DateTime start, {
    String calendar = 'work',
    Duration length = const Duration(hours: 1),
    bool allDay = false,
  }) => ExternalEvent(
    id: '$title-$start',
    calendarId: calendar,
    title: title,
    start: start,
    end: start.add(length),
    isAllDay: allDay,
  );

  // TestApp's "now" is 29 September 2026, 10:00.
  final source = FakeExternalCalendarSource(
    calendars: [work, family],
    events: [
      event('Dentist', DateTime(2026, 9, 29, 16, 30)),
      event(
        'Birthday',
        DateTime(2026, 9, 29),
        calendar: 'family',
        allDay: true,
        length: const Duration(days: 1),
      ),
      event('Team sync', DateTime(2026, 9, 30, 9)),
      event('Retro', DateTime(2026, 9, 28, 15)),
    ],
  );

  const enabled = AppSettings(
    localeCode: 'en',
    externalCalendars: ExternalCalendarSettings(enabled: true),
  );

  Future<void> openSettingsPage(WidgetTester tester) async {
    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Device calendars'));
    await tester.pumpAndSettle();
  }

  test('events of a day: all-day first, then by start', () {
    final sorted = sortedForDay([
      event('B', DateTime(2026, 9, 29, 12)),
      event('A', DateTime(2026, 9, 29, 8)),
      event('Holiday', DateTime(2026, 9, 29), allDay: true),
    ]);
    expect(sorted.map((e) => e.title), ['Holiday', 'A', 'B']);
  });

  test('calendar preferences survive persistence', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = StoredSettingsRepository(DriftKeyValueStore(db));
    expect((await repository.load()).externalCalendars.enabled, isFalse);

    await repository.save(
      const AppSettings(
        externalCalendars: ExternalCalendarSettings(enabled: true, hiddenCalendarIds: {'x'}),
      ),
    );
    final loaded = (await repository.load()).externalCalendars;
    expect(loaded.enabled, isTrue);
    expect(loaded.hiddenCalendarIds, {'x'});
  });

  testWidgets('nothing is shown until the user turns calendars on', (tester) async {
    await tester.pumpWidget(
      TestApp(
        settings: const AppSettings(localeCode: 'en'),
        externalCalendars: source,
      ).build(),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('in your calendars'), findsNothing);
  });

  testWidgets('Home lists the day events and adds one as an activity', (tester) async {
    final app = TestApp(settings: enabled, externalCalendars: source);
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();

    await tester.tap(find.text('2 events in your calendars'));
    await tester.pumpAndSettle();
    expect(find.text('Birthday'), findsOneWidget);
    expect(find.text('All day'), findsOneWidget);
    expect(find.text('Dentist'), findsOneWidget);
    expect(find.text('Team sync'), findsNothing);

    // The event becomes a pre-filled activity at its start time.
    await tester.tap(
      find.descendant(
        of: find.ancestor(of: find.text('Dentist'), matching: find.byType(Row)).first,
        matching: find.text('Add as activity'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('New activity'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Dentist'), findsOneWidget);
    await tester.tap(find.text('Save').first);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    final created = (await container.read(activityRepositoryProvider).getAll()).single;
    expect(created.name, 'Dentist');
    expect(created.timeSlots.single, const TimeSlot.at(LocalTime(16, 30)));
  });

  testWidgets('hidden calendars are left out', (tester) async {
    final app = TestApp(
      settings: const AppSettings(
        localeCode: 'en',
        externalCalendars: ExternalCalendarSettings(enabled: true, hiddenCalendarIds: {'family'}),
      ),
      externalCalendars: source,
    );
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    expect(find.text('1 event in your calendars'), findsOneWidget);
  });

  testWidgets('summaries show the events; past days cannot add them', (tester) async {
    final app = TestApp(settings: enabled, externalCalendars: source);
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('28').last);
    await tester.pumpAndSettle();
    expect(find.text('From your calendars'), findsOneWidget);
    expect(find.text('Retro'), findsOneWidget);
    expect(find.text('Add as activity'), findsNothing);
  });

  testWidgets('turning calendars on asks the permission and lets choose calendars', (tester) async {
    final askable = FakeExternalCalendarSource(
      currentAccess: ExternalCalendarAccess.askable,
      calendars: [work, family],
    );
    final app = TestApp(
      settings: const AppSettings(localeCode: 'en'),
      externalCalendars: askable,
    );
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    await openSettingsPage(tester);

    expect(find.text('Calendars to show'), findsNothing);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(askable.requests, 1);
    expect((await app.settings.load()).externalCalendars.enabled, isTrue);
    expect(find.text('Calendars to show'), findsOneWidget);
    expect(find.text('me@work.com'), findsOneWidget);

    await tester.tap(find.text('Family'));
    await tester.pumpAndSettle();
    expect((await app.settings.load()).externalCalendars.hiddenCalendarIds, {'family'});
  });

  testWidgets('a denied permission keeps calendars off and points to settings', (tester) async {
    final denying = FakeExternalCalendarSource(
      currentAccess: ExternalCalendarAccess.askable,
      grantOnRequest: false,
    );
    final app = TestApp(
      settings: const AppSettings(localeCode: 'en'),
      externalCalendars: denying,
    );
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    await openSettingsPage(tester);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect((await app.settings.load()).externalCalendars.enabled, isFalse);
    expect(find.text('Yoo is not allowed to read your calendars.'), findsOneWidget);
    await tester.tap(find.text('Open settings'));
    expect(denying.settingsOpened, 1);
  });
}
