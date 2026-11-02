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
- **Undo a completion**: in today's daily summary the green check can be tapped (after a
  confirmation) to mark the activity as not done: counters lose their last time (3/3 → 2/3),
  partial activities go back to 0%. It returns to Home, reminders and widget follow. Past days
  cannot be reopened.
- **Not needed**: an activity can be marked "not needed" for a day (e.g. watering the plants
  after the rain), from the card menu, from its notification ("Not needed" button) or for a
  missed day. It leaves Home, its reminders stop, it counts neither as done nor as missed (the
  calendar day stays green, the export shows ➖ and leaves it out of the total) and it is neutral
  for goals. Undo: the snackbar right after, or the daily summary (today and later days).
  Notifications show at most three actions on Android: simple activities get Done · Not needed,
  partial ones 100% · Other % (25/50/75 or typed) · Not needed.
- **Goal decisions** (Goals tab, the monthly summary): a goal can be marked as completed by hand,
  moved to the next month or, once its month is over, left as not reached. Moving creates a copy
  with the same title and target in the next month (or the current one, for months long over),
  starting from zero; the linked activities follow the copy. A decided goal keeps the progress it
  had (`frozenProgress`), so relinking activities never rewrites past months. Goals of past
  months not reached and not decided appear under "To decide", with a dot on the Goals tab.
- **Backup**: Settings → Backup exports everything (activities with their history, goals,
  subtasks, language and appearance) as `Yoo-backup-YYYY-MM-DD.json`. Importing never deletes:
  missing rows are added, a row on both sides is replaced only when the backup's copy is newer,
  occurrences are matched by activity and day. The app icon and device calendars are not part of
  it (they belong to the device).
- **App icons**: six variants (Classic, Light, Dark, Ocean, Forest, Sunset). On Android the
  choice replaces the launcher icon: the app closes and is reopened from the new icon (launchers
  usually drop the old home screen shortcut). The opening animation starts from the same icon.
- **No deadlines** on activities or goals.
- **Splash**: an opening animation on every cold start.
- **Bundle id**: `com.app.yoo`.

## Current status (updated 2026-11-02)

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

### Phase 6 – Calendar screen (done)
`features/calendar/`: month view (table_calendar, swipe or arrows, tap the title to return to the
current month) with a dot per day from `dayMarkOf` (done / missed / planned). Tapping a day opens
its daily summary (future days list what is planned). Below, `MonthGoalsSection`
(`features/goals/presentation/`): goals of the month with live percentage; add (current and
future months), rename and delete through `GoalEditor`. The 100% notification comes from
`GoalService.checkCompletions` through the reminder gateway.

### Phase 7 – external calendars (done, device test pending)
`features/external_calendars/`: `ExternalCalendarSource` (pure interface, `EmptyExternalCalendarSource`
by default) implemented by `DeviceExternalCalendarSource` (device_calendar_plus, never writes).
Opt-in from Settings → "Device calendars" (asks the permission, then choose the calendars to
show; stored in `AppSettings.externalCalendars`). Events appear in Home as a compact row opening
a sheet, and in the daily summary. "Add as activity" opens the form pre-filled with name, date
and exact start time (today and later only). Android declares READ and WRITE_CALENDAR because the
plugin grants reading only with both; iOS has the usage descriptions in `Info.plist`.
Device test: turn the feature on, check the permission dialog, that real events (all-day,
recurring, other accounts) appear on the right days, hiding a calendar, and "Add as activity".

### Phase 8 – export and personalization (done)
- **Export** (`features/export/`): `MonthReport` (pure) → `MonthTextFormatter` (localized text,
  CRLF) → `ExportDestination`. Today `ShareExportDestination`: writes `Yoo-YYYY-MM.txt` (UTF-8
  with BOM) in the cache and opens the share sheet (save to Files/Drive or send). The Export
  screen previews the text; months up to the current one.
- **Personalization** (`features/settings/presentation/personalization_screen.dart`): live
  preview, presets (choosing one drops the color overrides, keeps the font), a color for text,
  pages, headers/sheets, cards, navigation bar, buttons and notifications (swatches or
  "Default"), font (system, Inter, Nunito, Lora, JetBrains Mono: bundled static 400/600/700,
  SIL OFL, licenses registered in the license page), reset. Language or notification color
  changes reconfigure the notification channels/color and reschedule (`followReminderSettings`).
- **App icon**: see "Feedback after a month of use" below (the six icons are now real).
- **Goals tab**: became the monthly goal summary (see below).

### Phase 9 – polish (done)
- Large text: `test/polish/large_text_test.dart` opens every main screen on a 360×690 phone with
  2× text (English and Italian); layouts were fixed until nothing overflows (Home header area
  capped and scrollable, nav bar text scaling capped at 1.3, long trailing texts moved below).
- Placeholder launcher icon ("Classic" preview) on Android (adaptive + monochrome + legacy PNGs)
  and iOS; regenerate with `tool/generate_placeholder_icons.py` (needs Pillow).
- Settings → "About Yoo" opens the license page (font licenses included).
- Cleanup: unused dependencies and strings removed, Gradle template TODOs removed.
- Accessibility: calendar cells are announced with their full date by table_calendar, which also
  hides custom labels inside the cell, so the day status is only in the daily summary.

### Phase 10 – home screen widget (done on Android, device check pending)
Planned after phases 6–8; implemented once they were done. A home screen widget built with `home_widget` (Flutter side) and
Jetpack Glance (Android side); iOS is prepared in the Dart layer (a platform-neutral data model
and update service) but has no WidgetKit extension yet.
- Shows today's date and the activities still to do, with the colors of the user's theme
  (page, surface, card, text, accent and the activity border colors).
- Tapping a card completes it in background, reusing the notification action logic
  (`NotificationActionHandler`: "done" for counter activities, 100% for partial ones).
- Tapping the header opens the app on Home.
- Updated whenever activities change (same change hook as the reminders), and at midnight
  (the periodic background task plus the day watcher).

Implementation:
- Dart (`features/home_widget/`): `WidgetSnapshot` (pure model: theme colors, today and
  tomorrow with their open activities, "open Yoo" text for stale data) and `WidgetLinks`
  (`yoo://complete?activity&date&action`, `yoo://home`); `HomeWidgetUpdater` builds it from the
  repositories (works in background isolates); `HomeScreenWidget` interface with
  `AndroidHomeScreenWidget` (home_widget: save JSON under `yoo_widget`, redraw, schedule redraws
  at the next two midnights) and a no-op elsewhere (iOS: add a WidgetKit extension implementing
  it, reading the same JSON from an App Group).
- Refresh: change hook (after reminders), `DayWatcher`, periodic task, theme/language changes
  (`followWidgetSettings`).
- No deep links: `flutter_deeplinking_enabled` is off in the manifest, otherwise the header's
  `yoo://home` reached go_router as a page ("no routes for location"); go_router's `onException`
  also sends any unknown location to Home.
- Card tap: Glance `CompleteActivityAction` → `HomeWidgetBackgroundIntent` →
  `onHomeWidgetInteraction` (bootstrap.dart) → `NotificationActionHandler` ("done", or 100% for
  partial activities) → change hook → widget refreshed. Header tap opens `yoo://home`, which the
  app routes to Home.
- Android (`kotlin/com/app/yoo/widget/YooWidget.kt`): Glance widget, picks the snapshot day equal
  to the device date; Compose compiler plugin in Gradle; receivers in the manifest.
- Device check: add the widget from the launcher, check colors (light and dark themes), tap a
  card (it disappears and Home updates), tap the header (opens Home), day change at midnight.

### Device test on 2026-09-30 (Motorola edge 60, Android 16)
Verified: reminder fired with the app process killed; "Done" from the notification completed
the activity in background; device calendar events (all-day holiday) in Home with "Add as
activity" pre-filling name and date; export share sheet, file with BOM and emoji. Fixed
afterwards: CRLF in the exported file, lists behind the edge-to-edge navigation bar, black border
swatch invisible on dark themes. Not tested: reboot (it would restart the owner's phone), partial
actions and typed percentage from the notification (unit-tested).

### Subtasks, quantity goals, card styles (2026-09-30)
Subtasks per activity (checked per day), goals with a target amount ("3 / 4"), "one day only"
and "every N weeks" repeats, five card styles and an activity text size. Schema 2 (additive:
`goals.target`, `subtasks`, `subtask_checks`).

### Feedback after a month of use (2026-11-02)
- **Not needed** (rules above): `OccurrenceStatus.notNeeded`, stored in the existing `status`
  column (no schema change); `ActivityService.markNotNeeded` / `undoNotNeeded`;
  `ReminderActions.notNeeded`. The old "50%" action id is still handled for notifications already
  on screen.
- **Logo and app icons**: `tool/generate_icons.py` (replaces the placeholder script) generates
  the six adaptive icons (vector background with gradient, vector "Y", shared monochrome layer),
  legacy PNGs and the iOS app icon. `YooIcon` (`core/widgets/yoo_icon.dart`) draws the same
  artwork in the app. Android switching (`AppIcons.kt`): MainActivity is the Classic launcher
  entry, each other icon is a disabled launcher `<activity>` subclassing it; exactly one is
  enabled. Real activities rather than `activity-alias`, because MainActivity gets disabled and
  `flutter run` only looks for a launcher `<activity>`. The widget header opens the enabled
  entry (redrawn after a switch). At startup the stored choice follows the launcher
  (`followLauncherIcon`). Opening animation: the first frame is deferred until the settings are
  loaded, then it starts exactly like the Android 12+ system splash (the icon in a 160 dp circle
  on `yoo_splash`) and morphs into the logo and the theme colors.
- **Goals tab**: "To decide" (past goals not reached), this month, coming months, past months.
  Tapping a goal (here or in the calendar) opens its actions. Schema 3 (additive: `goals.outcome`,
  `frozen_progress`, `resolved_at`, `moved_from_id`), with a migration test from schema 2.
- **Backup** (`features/backup/`): `BackupFile` (JSON envelope: format, version, schema, rows by
  table as Drift JSON), `DriftBackupStore` (export / merge in one transaction), `BackupService`
  (settings, then day rollover and change hook). Import on Android through the system file picker
  (`com.app.yoo/files` channel in MainActivity); the export goes through the share sheet.
- Development note: after switching to a non-Classic icon, MainActivity is disabled and
  `flutter run` cannot start it. Switch back to Classic first, or run
  `adb shell pm enable com.app.yoo/.MainActivity`.

### Open items (need the owner, a device or a Mac)
- **Device tests**: reboot with pending reminders, partial/typed-percentage notification actions,
  the home screen widget (phase 10).
- **Release signing**: `android/app/build.gradle.kts` signs release builds with the debug key; a
  release keystore (kept out of git) is needed before publishing.
- **iOS**: never built (no Mac). Also: Italian permission texts need an `it.lproj/InfoPlist.strings`
  added through Xcode.
- **Device checks for 2026-11-02**: switch the app icon (the app closes, the new icon is in the
  app drawer, the widget header and notifications open the app), the opening animation from the
  system splash, "Not needed" from a notification, export a backup to Drive and import it.
- **iOS**: alternate app icons (Info.plist + assets, needs Xcode) and a document picker for
  backups; today the icon choice only changes the logo there and importing is hidden.
- **Build warning**: flutter_timezone, workmanager_android and home_widget still apply the Kotlin Gradle Plugin;
  future Flutter versions will refuse it until those plugins are updated (already at their latest
  versions).
