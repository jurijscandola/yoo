import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/services.dart';
import '../../../core/time/clock.dart';
import '../../settings/presentation/settings_providers.dart';
import '../data/drift_backup_store.dart';
import '../domain/backup_service.dart';

/// Where backups to import come from. Overridden at bootstrap on Android.
final backupFileSourceProvider = Provider<BackupFileSource>(
  (ref) => const UnsupportedBackupFileSource(),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    store: DriftBackupStore(ref.watch(databaseProvider)),
    settings: ref.watch(settingsRepositoryProvider),
    clock: ref.watch(clockProvider),
    // Imported days may be in the past: run the day rollover, then refresh
    // goals, reminders and the home screen widget.
    afterImport: () async {
      await ref.read(activityServiceProvider).rollover();
      await ref.read(changeHookProvider)({ref.read(clockProvider).today()});
    },
  ),
);
