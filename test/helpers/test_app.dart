import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:yoo/app/app.dart';
import 'package:yoo/app/providers.dart';
import 'package:yoo/core/database/app_database.dart';
import 'package:yoo/core/time/clock.dart';
import 'package:yoo/features/export/domain/export_destination.dart';
import 'package:yoo/features/export/presentation/export_providers.dart';
import 'package:yoo/features/external_calendars/domain/external_calendar_source.dart';
import 'package:yoo/features/external_calendars/presentation/external_calendar_providers.dart';
import 'package:yoo/features/reminders/domain/reminder_gateway.dart';
import 'package:yoo/features/reminders/domain/reminder_permissions.dart';
import 'package:yoo/features/reminders/presentation/reminder_providers.dart';
import 'package:yoo/features/settings/data/in_memory_settings_repository.dart';
import 'package:yoo/features/settings/domain/app_settings.dart';
import 'package:yoo/features/settings/presentation/settings_providers.dart';

/// Everything a widget test needs to run the full app in memory.
///
/// The in-memory database is not closed in tear-down: closing it inside the
/// fake-async test zone can wait forever after a failure (hence the drift
/// warning about several open databases is silenced).
class TestApp {
  TestApp({
    AppSettings settings = const AppSettings(),
    DateTime? now,
    this.permissions = const GrantedReminderPermissions(),
    this.gateway = const NoopReminderGateway(),
    this.externalCalendars = const EmptyExternalCalendarSource(),
    this.exportDestination = const NoopExportDestination(),
  }) : database = AppDatabase(
         // Synchronous stream closing avoids pending timers in widget tests.
         DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
       ),
       settings = InMemorySettingsRepository(settings),
       clock = FixedClock(now ?? DateTime(2026, 9, 29, 10)) {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  }

  final AppDatabase database;
  final InMemorySettingsRepository settings;
  final FixedClock clock;

  /// Reminder permissions; all granted unless a test is about them.
  final ReminderPermissions permissions;

  /// Notification system; does nothing unless a test inspects it.
  final ReminderGateway gateway;

  /// Device calendars; none unless a test is about them.
  final ExternalCalendarSource externalCalendars;

  /// Where exports go; discarded unless a test inspects them.
  final ExportDestination exportDestination;

  /// Provider overrides wiring the in-memory implementations.
  List<Override> get overrides => [
    databaseProvider.overrideWithValue(database),
    settingsRepositoryProvider.overrideWithValue(settings),
    clockProvider.overrideWithValue(clock),
    reminderPermissionsProvider.overrideWithValue(permissions),
    reminderGatewayProvider.overrideWithValue(gateway),
    externalCalendarSourceProvider.overrideWithValue(externalCalendars),
    exportDestinationProvider.overrideWithValue(exportDestination),
  ];

  /// The whole app, ready to pump.
  Widget build() => ProviderScope(overrides: overrides, child: const YooApp());
}
