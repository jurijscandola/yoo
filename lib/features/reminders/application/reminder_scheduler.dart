import 'dart:async';

import '../../../core/time/clock.dart';
import '../../activities/domain/repositories/activity_repository.dart';
import '../../activities/domain/repositories/occurrence_repository.dart';
import '../domain/notification_planner.dart';
import '../domain/reminder_gateway.dart';

/// Keeps the device notification schedule equal to what the planner wants.
///
/// [refresh] is idempotent: it cancels reminders that are no longer planned
/// and (re)schedules the planned ones with stable ids. It runs after every
/// data change, on app start/resume and periodically in background, which
/// keeps the rolling window full and follows time zone changes.
class ReminderScheduler {
  ReminderScheduler({
    required this._activities,
    required this._occurrences,
    required this._gateway,
    required this._clock,
    required this._labels,
    this._planner = const NotificationPlanner(),
  });

  final ActivityRepository _activities;
  final OccurrenceRepository _occurrences;
  final ReminderGateway _gateway;
  final Clock _clock;
  final Future<ReminderLabels> Function() _labels;
  final NotificationPlanner _planner;

  Future<void>? _running;
  bool _again = false;

  /// Recomputes and applies the schedule. Concurrent calls are coalesced into
  /// at most one extra run, so bursts of changes do not pile up.
  Future<void> refresh() {
    if (_running != null) {
      _again = true;
      return _running!;
    }
    final run = _refreshLoop();
    _running = run;
    return run;
  }

  Future<void> _refreshLoop() async {
    try {
      do {
        _again = false;
        await _apply();
      } while (_again);
    } finally {
      _running = null;
    }
  }

  Future<void> _apply() async {
    await _gateway.syncTimeZone();
    final now = _clock.now();
    final planned = _planner.plan(
      now: now,
      activities: await _activities.getAll(),
      stored: await _occurrences.getFrom(_clock.today()),
    );
    final wanted = {for (final r in planned) r.id};

    for (final id in await _gateway.pendingIds()) {
      if (!wanted.contains(id)) await _gateway.cancel(id);
    }
    final labels = await _labels();
    for (final reminder in planned) {
      await _gateway.schedule(reminder, labels);
    }
  }
}
