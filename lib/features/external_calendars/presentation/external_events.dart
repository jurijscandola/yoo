import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../core/time/date_labels.dart';
import '../../../core/time/local_date.dart';
import '../../../core/time/local_time.dart';
import '../../../l10n/l10n.dart';
import '../domain/external_calendar_source.dart';
import 'external_calendar_providers.dart';

/// Events of the device calendars on [date], for the daily summary. Nothing
/// is drawn when there are none (or the feature is off).
class ExternalEventsSection extends ConsumerWidget {
  const ExternalEventsSection({super.key, required this.date});

  final LocalDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(externalEventsOnProvider(date)).value ?? const [];
    if (events.isEmpty) return const SizedBox.shrink();
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              context.l10n.externalSectionTitle,
              style: TextStyle(color: t.textMuted, fontWeight: FontWeight.w600),
            ),
          ),
          _EventList(events: events, date: date),
        ],
      ),
    );
  }
}

/// Compact row for Home: "3 events in your calendars", opening the list.
class ExternalEventsBanner extends ConsumerWidget {
  const ExternalEventsBanner({super.key, required this.date});

  final LocalDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(externalEventsOnProvider(date)).value ?? const [];
    if (events.isEmpty) return const SizedBox(width: double.infinity);
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(t.radius),
          onTap: () => _openSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.event_outlined, color: t.textMuted, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.externalEventsCount(events.length),
                    style: TextStyle(color: t.text, fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(Icons.expand_more, color: t.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final events = ref.watch(externalEventsOnProvider(date)).value ?? const [];
          final t = context.tokens;
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Text(
                    context.l10n.externalSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.externalReadOnly,
                    style: TextStyle(color: t.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  _EventList(events: events, date: date, closeSheet: true),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({required this.events, required this.date, this.closeSheet = false});

  final List<ExternalEvent> events;
  final LocalDate date;
  final bool closeSheet;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(t.radius),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, e) in events.indexed) ...[
            if (i > 0) Divider(height: 1, indent: 28, color: t.divider),
            ExternalEventTile(event: e, date: date, closeSheet: closeSheet),
          ],
        ],
      ),
    );
  }
}

/// One read-only event with the "Add as activity" shortcut (today and later).
class ExternalEventTile extends ConsumerWidget {
  const ExternalEventTile({
    super.key,
    required this.event,
    required this.date,
    this.closeSheet = false,
  });

  final ExternalEvent event;
  final LocalDate date;

  /// Whether the tile lives in a bottom sheet to close before navigating.
  final bool closeSheet;

  /// Exact time for the new activity: the event start, when it is on [date].
  LocalTime? get _startTime {
    if (event.isAllDay || LocalDate.fromDateTime(event.start) != date) return null;
    return LocalTime(event.start.hour, event.start.minute);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final canAdd = !date.isBefore(ref.watch(todayProvider));
    final when = event.isAllDay
        ? l10n.externalAllDay
        : '${context.timeLabel(LocalTime(event.start.hour, event.start.minute))} – '
              '${context.timeLabel(LocalTime(event.end.hour, event.end.minute))}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: event.colorArgb == null ? t.accent : Color(event.colorArgb!),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: t.text, fontWeight: FontWeight.w500),
                ),
                Text(when, style: TextStyle(color: t.textMuted, fontSize: 13)),
              ],
            ),
          ),
          if (canAdd)
            TextButton(
              onPressed: () {
                // Read the router first: closing the sheet unmounts this tile.
                final router = GoRouter.of(context);
                if (closeSheet) Navigator.of(context).pop();
                router.push(Routes.newActivity(name: event.title, date: date, time: _startTime));
              },
              child: Text(l10n.externalAddAsActivity),
            ),
        ],
      ),
    );
  }
}
