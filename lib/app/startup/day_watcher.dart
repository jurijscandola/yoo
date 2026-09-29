import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../services.dart';

/// Keeps stored data aligned with the current day while the app runs: runs
/// the day rollover on start, when the app returns to the foreground and at
/// every local midnight. Also exposes today's date through [todayProvider].
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

  /// Runs the rollover and re-arms the midnight timer.
  void _onNewMoment() {
    ref.invalidate(todayProvider);
    unawaited(ref.read(activityServiceProvider).rollover());
    _midnight?.cancel();
    final now = ref.read(clockProvider).now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    // A few seconds of margin so the new day has really started.
    _midnight = Timer(nextMidnight.difference(now) + const Duration(seconds: 2), _onNewMoment);
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
