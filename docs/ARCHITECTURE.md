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
