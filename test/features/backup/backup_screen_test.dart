import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/app/services.dart';
import 'package:yoo/core/time/local_date.dart';
import 'package:yoo/core/time/local_time.dart';
import 'package:yoo/features/activities/domain/entities/activity.dart';
import 'package:yoo/features/activities/domain/entities/activity_draft.dart';
import 'package:yoo/features/activities/domain/entities/recurrence.dart';
import 'package:yoo/features/backup/domain/backup_service.dart';
import 'package:yoo/features/export/domain/export_destination.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';

import '../../helpers/test_app.dart';

/// Records exported files.
class _RecordingDestination implements ExportDestination {
  final files = <(String, String, String)>[];

  @override
  Future<void> deliver({
    required String fileName,
    required String content,
    String? subject,
    String mimeType = 'text/plain',
  }) async => files.add((fileName, content, mimeType));
}

/// Hands out a given text as the picked file.
class _FakeFiles implements BackupFileSource {
  _FakeFiles(this.text);

  final String? text;

  @override
  bool get isSupported => true;

  @override
  Future<String?> pickText() async => text;
}

void main() {
  const english = AppSettings(localeCode: 'en');

  Future<void> openBackup(WidgetTester tester, TestApp app) async {
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Backup'));
    await tester.pumpAndSettle();
  }

  testWidgets('export on one phone, import on another', (tester) async {
    final destination = _RecordingDestination();
    final oldPhone = TestApp(settings: english, exportDestination: destination);
    await tester.pumpWidget(oldPhone.build());
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    await container
        .read(activityServiceProvider)
        .create(
          ActivityDraft(
            name: 'Water the plants',
            notificationText: 'Water them',
            borderColorIndex: 2,
            recurrence: const DailyRecurrence(),
            timeSlots: const [TimeSlot.at(LocalTime(8, 0))],
            startDate: LocalDate(2026, 9, 29),
          ),
        );
    await openBackup(tester, oldPhone);
    // Without a file picker, importing is not offered.
    expect(find.text('Importing is not available on this device yet.'), findsOneWidget);

    await tester.tap(find.text('Export backup'));
    await tester.pumpAndSettle();
    final (name, content, mimeType) = destination.files.single;
    expect(name, 'Yoo-backup-2026-09-29.json');
    expect(mimeType, 'application/json');

    // A new phone: the same backup comes back from the file picker.
    await tester.pumpWidget(const SizedBox());
    final newPhone = TestApp(settings: english, backupFiles: _FakeFiles(content));
    await openBackup(tester, newPhone);
    await tester.tap(find.text('Import backup'));
    await tester.pumpAndSettle();
    expect(find.text('Import this backup?'), findsOneWidget);
    expect(find.text('Activities: 1'), findsOneWidget);
    expect(find.text('Days of history: 1'), findsOneWidget);
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Backup imported'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Water the plants'), findsOneWidget);
  });

  testWidgets('a file that is not a backup is refused', (tester) async {
    final app = TestApp(settings: english, backupFiles: _FakeFiles('Yoo · September 2026'));
    await openBackup(tester, app);
    await tester.tap(find.text('Import backup'));
    await tester.pumpAndSettle();
    expect(find.text('This file is not a Yoo backup.'), findsOneWidget);
    expect(find.text('Import this backup?'), findsNothing);
  });
}
