import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/external_calendars/presentation/external_calendar_providers.dart';
import '../providers.dart';
import '../services.dart';

/// Keeps stored data aligned with the current day while the app runs: runs
/// the day rollover on start, when the app returns to the foreground and at
/// every local midnight, then refreshes the reminders (keeps the rolling
/// window full and follows time zone changes). Also exposes today's date
/// through [todayProvider].
class DayWatcher extends ConsumerStatefulWidget {
  const DayWatcher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DayWatcher> createState() => _DayWatcherState();
}

class _DayWatcherState extends ConsumerState<DayWatcher> with WidgetsBindingObserver {
  Timer? _midnight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _onNewMoment();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _onNewMoment();
  }

  /// Runs the rollover, refreshes the reminders and re-arms the midnight timer.
  void _onNewMoment() {
    ref.invalidate(todayProvider);
    // Device calendars may have changed while the app was in background.
    ref.invalidate(externalCalendarAccessProvider);
    ref.invalidate(externalEventsOnProvider);
    unawaited(_rolloverAndRefresh());
    _midnight?.cancel();
    final now = ref.read(clockProvider).now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    // A few seconds of margin so the new day has really started.
    _midnight = Timer(nextMidnight.difference(now) + const Duration(seconds: 2), _onNewMoment);
  }

  Future<void> _rolloverAndRefresh() async {
    // Read before awaiting: the widget may be disposed meanwhile.
    final activities = ref.read(activityServiceProvider);
    final refreshReminders = ref.read(reminderRefreshProvider);
    await activities.rollover();
    await refreshReminders();
  }

  @override
  void dispose() {
    _midnight?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
