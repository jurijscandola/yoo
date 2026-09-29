import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/database/app_database.dart';
import 'features/settings/data/stored_settings_repository.dart';
import 'features/settings/presentation/settings_providers.dart';

/// Entry point of Yoo: opens the local database and wires the persistent
/// implementations into the provider graph.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.open();
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        settingsRepositoryProvider.overrideWith(
          (ref) => StoredSettingsRepository(ref.watch(keyValueStoreProvider)),
        ),
      ],
      child: const YooApp(),
    ),
  );
}
