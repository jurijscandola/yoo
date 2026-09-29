import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:yoo/app/app.dart';
import 'package:yoo/app/providers.dart';
import 'package:yoo/core/database/app_database.dart';
import 'package:yoo/core/time/clock.dart';
import 'package:yoo/features/settings/data/in_memory_settings_repository.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';
import 'package:yoo/features/settings/presentation/settings_providers.dart';

/// Everything a widget test needs to run the full app in memory.
///
/// The in-memory database is not closed in tear-down: closing it inside the
/// fake-async test zone can wait forever after a failure.
class TestApp {
  TestApp({AppSettings settings = const AppSettings(), DateTime? now})
    : database = AppDatabase(
        // Synchronous stream closing avoids pending timers in widget tests.
        DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
      ),
      settings = InMemorySettingsRepository(settings),
      clock = FixedClock(now ?? DateTime(2026, 9, 29, 10));

  final AppDatabase database;
  final InMemorySettingsRepository settings;
  final FixedClock clock;

  /// Provider overrides wiring the in-memory implementations.
  List<Override> get overrides => [
    databaseProvider.overrideWithValue(database),
    settingsRepositoryProvider.overrideWithValue(settings),
    clockProvider.overrideWithValue(clock),
  ];

  /// The whole app, ready to pump.
  Widget build() => ProviderScope(overrides: overrides, child: const YooApp());
}
