import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/yoo_palettes.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/l10n.dart';
import '../../activities/domain/entities/occurrence.dart';
import '../../activities/domain/services/occurrence_planner.dart';
import '../../activities/presentation/activity_providers.dart';
import '../../activities/presentation/widgets/activity_sheets.dart';
import '../../home/presentation/widgets/day_header.dart';

/// Daily summary: every activity of a day with ✅ (completed) or ❌ (not
/// completed), plus the percentage reached by partial activities.
///
/// Future days list what is planned. Missed entries can still be resolved.
class DailySummaryScreen extends ConsumerWidget {
  const DailySummaryScreen({super.key, required this.date, this.extraSections = const []});

  final LocalDate date;

  /// Extra content below the list (e.g. external calendar events).
  final List<Widget> extraSections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final today = ref.watch(todayProvider);
    final entries = ref.watch(dayEntriesProvider(date)).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.summaryTitle)),
      // Keeps the end of the list above the system navigation bar
      // (edge-to-edge on Android 15+).
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            DayHeader(date: date, today: today),
            if (entries != null && entries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(l10n.summaryEmpty, style: TextStyle(color: t.textMuted)),
                ),
              ),
            if (entries != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(t.radius),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (final (i, entry) in entries.indexed) ...[
                        if (i > 0) Divider(height: 1, indent: 56, color: t.divider),
                        _SummaryRow(entry: entry, today: today),
                      ],
                    ],
                  ),
                ),
              ),
            ...extraSections,
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends ConsumerWidget {
  const _SummaryRow({required this.entry, required this.today});

  final DayEntry entry;
  final LocalDate today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final o = entry.occurrence;
    final activity = entry.activity;
    final status = _statusOf(o);

    final details = <String>[
      if (activity.isPartial && o != null) l10n.percent(o.progress),
      if (!activity.isPartial && activity.timesPerDay > 1 && o != null)
        l10n.timesDone(o.completedCount, activity.timesPerDay),
      if (o?.resolution == MissedResolution.moved) l10n.summaryMoved,
      if (o?.retroactive ?? false) l10n.summaryCompletedLater,
      if (status == _Status.planned) l10n.summaryPlanned,
      if (status == _Status.pending) l10n.summaryPending,
    ];

    final resolvable =
        o != null && o.status == OccurrenceStatus.missed && o.resolution != MissedResolution.moved;

    return ListTile(
      leading: _StatusIcon(status: status),
      title: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: YooPalettes.borderColor(activity.borderColorIndex),
              shape: BoxShape.circle,
            ),
          ),
          Flexible(child: Text(activity.name)),
        ],
      ),
      subtitle: details.isEmpty
          ? null
          : Text(details.join(' · '), style: TextStyle(color: t.textMuted)),
      trailing: resolvable ? Icon(Icons.chevron_right, color: t.textMuted) : null,
      onTap: resolvable ? () => ActivitySheets.resolveMissed(context, ref, o, activity) : null,
    );
  }

  _Status _statusOf(Occurrence? o) {
    if (o == null) return entry.date.isAfter(today) ? _Status.planned : _Status.pending;
    return switch (o.status) {
      OccurrenceStatus.completed => _Status.done,
      OccurrenceStatus.missed => _Status.missed,
      OccurrenceStatus.pending => entry.date.isAfter(today) ? _Status.planned : _Status.pending,
      OccurrenceStatus.skipped => _Status.planned,
    };
  }
}

enum _Status { done, missed, pending, planned }

/// ✅ green check, ❌ red cross, or a neutral marker for open/planned entries.
class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final _Status status;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return switch (status) {
      _Status.done => Icon(Icons.check_circle_rounded, color: t.success, size: 28),
      _Status.missed => Icon(Icons.cancel_rounded, color: t.danger, size: 28),
      _Status.pending => Icon(Icons.radio_button_unchecked, color: t.textMuted, size: 28),
      _Status.planned => Icon(Icons.schedule_rounded, color: t.textMuted, size: 28),
    };
  }
}
