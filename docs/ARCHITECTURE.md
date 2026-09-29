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

### Repository
The git repository is `yoo/` (this folder), pushed to `github.com/jurijscandola/yoo` (`master`).
The parent folder `Yoo/` also contains an older `.git` with only a scaffold snapshot: it is not
used anymore and can be deleted.

### Resolved issue: hanging widget tests
Widget tests hung for 10 minutes after any failure. Cause: closing the in-memory Drift database
in `addTearDown` inside the fake-async zone never completes. Fix: widget tests no longer close
the DB (see `test/helpers/test_app.dart`). Also, `find.bySemanticsLabel` needs semantics enabled:
tests find the check button by icon instead.

### Phase 5 – notifications: code complete, device test pending
Done and committed (steps 1–8, 85 tests green, debug and release APK build):
- **Wiring** (`features/reminders/presentation/reminder_providers.dart`, `app/services.dart`):
  `reminderGatewayProvider` (Noop by default), `reminderPermissionsProvider` (always granted by
  default), `reminderSchedulerProvider` (single instance), `reminderStringsProvider` (localized
  strings without a `BuildContext`). `reminderRefreshProvider` and
  `goalCompletionNotifierProvider` use them; notification failures are logged, never propagated
  to the data change that triggered them.
- **Bootstrap** (`app/bootstrap.dart`, `main.dart`): `openAppContainer` builds the provider
  graph on the shared DB with the real `LocalNotificationGateway`; the gateway is initialized
  before `runApp` (scheduling needs time zones). Foreground responses and the
  `@pragma('vm:entry-point')` background handler both go through `handleNotificationResponse`
  (`NotificationActionHandler` + refresh). `runInBackground` gives background isolates a
  temporary container and closes it afterwards.
- **Refresh triggers**: every data change (change hook), `DayWatcher` after each rollover (start,
  resume, midnight), the permission prompt, and the workmanager periodic task
  (`app/background_tasks.dart`, id `com.app.yoo.refresh`, ~1 h: rollover + refresh).
- **Android**: `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, the three
  flutter_local_notifications receivers, small icon `drawable/ic_stat_yoo` (kept from resource
  shrinking by `res/raw/keep.xml`), app label `Yoo`.
- **iOS** (not buildable here, no Mac): BGTask id in `Info.plist` (+ `fetch` background mode),
  workmanager registration and registrant, notification center delegate,
  `FlutterLocalNotificationsPlugin.setPluginRegistrantCallback` in
  `didInitializeImplicitFlutterEngine`.
- **Permissions**: after the splash and the language choice, `StartupGate` explains and asks
  notifications, then exact alarms (skipped if notifications are denied). Shown once
  (`StoreKeys.permissionsAsked`). Settings has a "Reminder reliability" section: status of
  notifications / exact alarms (tap to fix; opens system settings once denied) and the battery
  optimization hint (Android only).
- **Tests**: `test/features/reminders/application/` (scheduler with `FakeReminderGateway`, action
  handler on the in-memory DB), `test/features/reminders/presentation/permission_flow_test.dart`.

Still to do for Phase 5:
9. Manual test on a real Android device. The phone connected on 2026-09-29 was not detected
   (neither by `adb devices` nor as a USB device in Windows). Checklist once it is:
   `flutter run`; permission prompts; a reminder a few minutes ahead fires with the app closed;
   "Done" / 100% / 50% / typed % from the notification update Home; follow-ups stop at 100%;
   reminders survive a reboot; goal-reached notification; language change updates action labels.

### Next phases
6 Calendar screen + monthly goals UI · 7 external calendars (`device_calendar_plus`) ·
8 export + personalization · 9 polish.
