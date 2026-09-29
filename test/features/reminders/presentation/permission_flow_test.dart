import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';

import '../../../helpers/fake_reminder_gateway.dart';
import '../../../helpers/test_app.dart';

void main() {
  const english = AppSettings(localeCode: 'en');

  Future<void> restart(WidgetTester tester, TestApp app) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
  }

  testWidgets('first run explains and asks notifications, then exact alarms, once', (tester) async {
    final permissions = FakeReminderPermissions();
    final app = TestApp(settings: english, permissions: permissions);
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();

    expect(find.text('Allow reminders'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Allow reminders'), findsNothing);
    expect(find.text('Precise reminders'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Precise reminders'), findsNothing);
    expect(permissions.requests, ['notifications', 'exactAlarms']);

    // Even if the user revokes them later, the prompt is not repeated.
    permissions
      ..notifications = false
      ..exactAlarms = false;
    await restart(tester, app);
    expect(find.text('Allow reminders'), findsNothing);
  });

  testWidgets('"Not now" closes the prompt without asking the system', (tester) async {
    final permissions = FakeReminderPermissions();
    final app = TestApp(settings: english, permissions: permissions);
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('Allow reminders'), findsNothing);
    expect(find.text('Precise reminders'), findsNothing);
    expect(permissions.requests, isEmpty);

    await restart(tester, app);
    expect(find.text('Allow reminders'), findsNothing);
  });

  testWidgets('denied notifications skip the exact alarm prompt', (tester) async {
    final permissions = FakeReminderPermissions()..grantOnRequest = false;
    final app = TestApp(settings: english, permissions: permissions);
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Precise reminders'), findsNothing);
    expect(permissions.requests, ['notifications']);
  });

  testWidgets('the language prompt comes before the permission prompt', (tester) async {
    final app = TestApp(permissions: FakeReminderPermissions());
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();

    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('Allow reminders'), findsNothing);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Allow reminders'), findsOneWidget);
  });

  testWidgets('settings show what is missing and fix it on tap', (tester) async {
    final permissions = FakeReminderPermissions(exactAlarms: true);
    final app = TestApp(settings: english, permissions: permissions);
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Battery optimization'), 100);
    expect(find.text('Reminder reliability'), findsOneWidget);
    expect(find.text('Not allowed'), findsOneWidget);
    expect(find.text('Allowed'), findsOneWidget);

    await tester.tap(find.text('Not allowed'));
    await tester.pumpAndSettle();
    expect(permissions.requests, ['notifications']);
    expect(find.text('Not allowed'), findsNothing);
    expect(find.text('Allowed'), findsNWidgets(2));

    await tester.tap(find.text('Open settings'));
    expect(permissions.requests.last, 'settings');
  });
}
