# Yoo — Architecture & product decisions

## Stack
- **Architecture**: Clean Architecture, feature-first (`lib/features/<feature>/{domain,data,presentation}`).
  `domain` is pure Dart (no Flutter imports) and holds entities, repository interfaces and pure
  services (recurrence, carry-over, notification planning, goal progress).
- **State / DI**: Riverpod 3 with hand-written providers (no codegen). Repositories are exposed
  through providers so future cloud/backend implementations can be swapped with overrides.
- **Persistence**: Drift (SQLite). All ids are UUID v4; rows carry `updatedAt` / `deletedAt`
  (soft delete) to make future sync possible.
- **Routing**: go_router with a `StatefulShellRoute` for the bottom navigation.
- **Notifications**: flutter_local_notifications + timezone + flutter_timezone, workmanager for
  periodic rescheduling. A rolling window of at most ~50 pending notifications is kept
  (iOS caps pending notifications at 64).
- **External calendars**: `device_calendar_plus` (read only) behind `ExternalCalendarSource`.
  `device_calendar` was rejected: unmaintained and pins an old `timezone`.
- **Localization**: gen-l10n, English (default) and Italian. Chosen on first launch, editable in
  Settings.
- **Platforms**: Android and iOS. Only Android is verified locally (Windows host, no Mac).

## Extension points (interfaces only, not implemented yet)
- `SyncService` / remote data sources: shared activities with accounts.
- `ExportDestination`: local file today, Google Drive later.
- `ExternalCalendarSource`: device calendars today, direct Google/Microsoft APIs later.

## Product rules agreed with the owner
- **Times per day**: one card with a counter (e.g. 1/3). Each time has its own notification.
- **Time slot**: the notification fires at a random time inside the slot (`from`–`to`). The
  random time is seeded by `activityId + date + slotIndex`, so rescheduling never moves it.
- **Partial completion**: free percentage (0–100). Extra fields at creation: number of reminders
  and "until" time; reminders are spread evenly until that time and stop at 100%.
- **Deleting from Home**: the user chooses "only this day" or "the whole activity".
- **Missed activities**: no automatic carry-over. At the end of the day an unfinished occurrence
  is marked ❌. On the next launch the user decides for each one:
  1. mark as completed (retroactive);
  2. move to tomorrow with the same settings (only if tomorrow has no occurrence of it);
  3. leave it as not completed.
  The same actions are available from the daily summary.
- **Goal progress**: `clamp(Σ ±impact × progress/100, 0, 100)` over linked occurrences of the
  month (+ additive, − subtractive). A notification fires once when a goal reaches 100%.
- **No deadlines** on activities or goals.
- **Splash**: an opening animation on every cold start.
- **Bundle id**: `com.app.yoo`.

## Current status (updated 2026-09-29)

### Done (committed)
- **Phase 0** – setup, bundle id `com.app.yoo`, dependencies, lints, l10n. (The Gradle helper
  script for the old `!` in the project path was removed: plain `flutter` builds Android now.)
- **Phase 1** – design tokens (`YooTokens`), presets/palettes, bottom navigation with the custom
  goals icon, opening animation on every cold start, first-launch language prompt, Goals skeleton,
  Settings screen (language works; export/personalization are "coming soon").
- **Phase 2** – pure domain logic + unit tests: recurrences, occurrences, missed-activity rules,
  notification planner (rolling window, seeded random time, partial follow-ups), goal progress.
- **Phase 3** – Drift database, repositories, `ActivityService`, `GoalService`, day rollover
  (`DayWatcher`: start, resume, midnight), integration tests on an in-memory DB.
- **Phase 4** – activity form, Home (swipeable days, animated cards, actions menu), missed
  activities prompt/banner, daily summary. Widget tests for the main flows. 69 tests green.

### Resolved issue: hanging widget tests
Widget tests hung for 10 minutes after any failure. Cause: closing the in-memory Drift database
in `addTearDown` inside the fake-async zone never completes. Fix: widget tests no longer close
the DB (see `test/helpers/test_app.dart`). Also, `find.bySemanticsLabel` needs semantics enabled:
tests find the check button by icon instead.

### In progress: Phase 5 – notifications (WIP commit, not wired yet)
Written, compiling, **not yet connected to the app and not tested**:
- `features/reminders/domain/reminder_gateway.dart` – gateway interface, action ids, labels.
- `features/reminders/application/reminder_scheduler.dart` – idempotent refresh (cancel stale,
  schedule planned, coalesced runs, time-zone sync).
- `features/reminders/application/notification_action_handler.dart` – done / 100% / 50% /
  typed percentage from the notification.
- `features/reminders/data/local_notification_gateway.dart` – flutter_local_notifications
  implementation (channels, iOS categories, exact vs inexact, permissions, time zones).
- New l10n strings for notifications and permissions.

Still to do for Phase 5:
1. Providers: `reminderGatewayProvider` (Noop default, real one overridden in `main`),
   `reminderSchedulerProvider`; override `reminderRefreshProvider` and
   `goalCompletionNotifierProvider` in `app/services.dart`.
2. Bootstrap in `main`: initialize the gateway with localized labels, foreground response
   handler, top-level `@pragma('vm:entry-point')` background handler that opens the shared DB in
   a `ProviderContainer`, runs `NotificationActionHandler` and refreshes reminders.
3. `DayWatcher`: also call the reminder refresh on resume.
4. workmanager: periodic task (~1 h) running rollover + refresh (keeps the window full, follows
   time-zone changes); iOS BGTask identifiers in Info.plist + AppDelegate registration.
5. AndroidManifest: `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, receivers
   `ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver` (BOOT_COMPLETED,
   MY_PACKAGE_REPLACED, QUICKBOOT_POWERON), `ActionBroadcastReceiver`; monochrome small icon
   drawable `ic_stat_yoo` (referenced by the gateway, **not created yet**).
6. iOS AppDelegate: `FlutterLocalNotificationsPlugin.setPluginRegistrantCallback` inside
   `didInitializeImplicitFlutterEngine` (UIScene) + notification center delegate.
7. Permission flow after the startup gate (explanation dialog → notifications → exact alarms)
   and a "Reminder reliability" section in Settings.
8. Tests: `ReminderScheduler` with a fake gateway, `NotificationActionHandler` on the in-memory DB.
9. Manual test on a real Android device (no emulator configured on this PC).

### Next phases
6 Calendar screen + monthly goals UI · 7 external calendars (`device_calendar_plus`) ·
8 export + personalization · 9 polish.
