import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../app/services.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../core/time/local_date.dart';
import '../../../core/widgets/diff_animated_list.dart';
import '../../../l10n/l10n.dart';
import '../../activities/domain/entities/occurrence.dart';
import '../../activities/domain/services/occurrence_planner.dart';
import '../../activities/presentation/activity_providers.dart';
import '../../activities/presentation/widgets/activity_card.dart';
import '../../activities/presentation/widgets/activity_sheets.dart';
import '../../external_calendars/presentation/external_events.dart';
import 'widgets/day_header.dart';

/// Page index of today in the day pager; pages to the right are later days.
const _todayPage = 100000;

/// The day shown on Home (shared with the "+" button).
final selectedDayProvider = NotifierProvider<SelectedDay, LocalDate>(SelectedDay.new);

/// Holds the day currently shown on Home.
class SelectedDay extends Notifier<LocalDate> {
  @override
  LocalDate build() => ref.watch(todayProvider);

  void select(LocalDate date) => state = date;
}

/// Home tab: the selected day with its activities. Swipe horizontally to
/// change day, tap the header for the daily summary.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _pager = PageController(initialPage: _todayPage);

  /// The missed-activities prompt opens automatically once per app session.
  static bool _missedPromptShown = false;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  LocalDate _dateOf(int page) => ref.read(todayProvider).addDays(page - _todayPage);

  void _goToToday() => _pager.animateToPage(
    _todayPage,
    duration: const Duration(milliseconds: 450),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);

    // A new day started while the app was open: follow it.
    ref.listen(todayProvider, (_, _) {
      if (_pager.hasClients) _pager.jumpToPage(_todayPage);
    });

    // Ask once per session about activities left undone.
    ref.listen(unresolvedMissedProvider, (_, next) {
      final missed = next.value ?? const [];
      if (missed.isNotEmpty && !_missedPromptShown) {
        _missedPromptShown = true;
        ActivitySheets.showMissedPrompt(context);
      }
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: context.l10n.newActivity,
        onPressed: () {
          final selected = ref.read(selectedDayProvider);
          context.push(Routes.newActivity(date: selected.isAfter(today) ? selected : null));
        },
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: SafeArea(
        bottom: false,
        child: PageView.builder(
          controller: _pager,
          onPageChanged: (page) => ref.read(selectedDayProvider.notifier).select(_dateOf(page)),
          itemBuilder: (context, page) {
            final date = today.addDays(page - _todayPage);
            return _DayPage(
              key: ValueKey(date),
              date: date,
              today: today,
              onBackToToday: _goToToday,
            );
          },
        ),
      ),
    );
  }
}

/// One day of the pager: header, missed banner (today) and the card list.
class _DayPage extends ConsumerWidget {
  const _DayPage({super.key, required this.date, required this.today, required this.onBackToToday});

  final LocalDate date;
  final LocalDate today;
  final VoidCallback onBackToToday;

  CardMode get _mode => date == today
      ? CardMode.actionable
      : date.isAfter(today)
      ? CardMode.preview
      : CardMode.missed;

  /// Which entries Home shows: what is still to do (today, future) or what
  /// was left undone (past days).
  bool _visible(DayEntry e) {
    final o = e.occurrence;
    return switch (_mode) {
      CardMode.actionable || CardMode.preview => o == null || o.isOpen,
      CardMode.missed =>
        o != null && o.status == OccurrenceStatus.missed && o.resolution != MissedResolution.moved,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(dayEntriesProvider(date));
    final missedCount = date == today
        ? (ref.watch(unresolvedMissedProvider).value?.length ?? 0)
        : 0;
    final visible = entries.value?.where(_visible).toList();

    return Column(
      children: [
        DayHeader(
          date: date,
          today: today,
          onTap: () => context.push(Routes.day(date)),
          onBackToToday: onBackToToday,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: missedCount == 0
              ? const SizedBox(width: double.infinity)
              : _MissedBanner(count: missedCount),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: ExternalEventsBanner(date: date),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: visible == null
                ? const SizedBox.shrink()
                : visible.isEmpty
                ? _EmptyDay(
                    key: const ValueKey('empty'),
                    allDone: _mode == CardMode.actionable && (entries.value?.isNotEmpty ?? false),
                  )
                : DiffAnimatedList<DayEntry>(
                    key: const ValueKey('list'),
                    items: visible,
                    keyOf: (e) => e.activity.id,
                    padding: const EdgeInsets.only(top: 4, bottom: 96),
                    itemBuilder: (context, entry, animation) =>
                        ListItemTransition(animation: animation, child: _card(context, ref, entry)),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, WidgetRef ref, DayEntry entry) {
    final service = ref.read(activityServiceProvider);
    final mode = _mode;
    return ActivityCard(
      key: ValueKey('card-${entry.activity.id}-$date'),
      entry: entry,
      mode: mode,
      onMenu: () => ActivitySheets.openMenu(context, ref, entry, mode),
      onTap: switch (mode) {
        CardMode.missed => () => ActivitySheets.openMenu(context, ref, entry, mode),
        CardMode.actionable when entry.activity.isPartial => () => ActivitySheets.openProgress(
          context,
          ref,
          entry,
        ),
        _ => null,
      },
      onComplete: mode != CardMode.actionable
          ? null
          : () async {
              if (entry.activity.isPartial) {
                await ActivitySheets.openProgress(context, ref, entry);
              } else {
                await service.markTimeDone(entry.activity.id, date);
              }
            },
    );
  }
}

/// Banner reminding the user about missed activities to decide on.
class _MissedBanner extends StatelessWidget {
  const _MissedBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: t.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(t.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(t.radius),
          onTap: () => ActivitySheets.showMissedPrompt(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.history_rounded, color: t.danger, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.missedBanner(count),
                    style: TextStyle(color: t.text, fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(Icons.chevron_right, color: t.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({super.key, required this.allDone});

  final bool allDone;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              allDone ? Icons.task_alt_rounded : Icons.wb_sunny_outlined,
              size: 44,
              color: allDone ? t.success : t.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              allDone ? l10n.homeAllDone : l10n.homeEmpty,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (!allDone) ...[
              const SizedBox(height: 4),
              Text(l10n.homeEmptyHint, style: TextStyle(color: t.textMuted)),
            ],
          ],
        ),
      ),
    );
  }
}
