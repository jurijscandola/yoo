import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/services.dart';
import '../../../../core/theme/yoo_palettes.dart';
import '../../../../core/theme/yoo_tokens.dart';
import '../../../../core/time/date_labels.dart';
import '../../../../core/time/local_date.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/occurrence.dart';
import '../../domain/services/occurrence_planner.dart';
import '../activity_providers.dart';
import 'activity_card.dart';

/// Bottom sheets and dialogs acting on activities, shared by Home, the daily
/// summary and the calendar.
abstract final class ActivitySheets {
  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Actions menu of a card: edit, postpone, remove for the day, delete.
  static Future<void> openMenu(
    BuildContext context,
    WidgetRef ref,
    DayEntry entry,
    CardMode mode,
  ) async {
    if (mode == CardMode.missed && entry.occurrence != null) {
      return resolveMissed(context, ref, entry.occurrence!, entry.activity);
    }
    final l10n = context.l10n;
    final service = ref.read(activityServiceProvider);
    final occurrence = entry.occurrence;
    final canPostpone =
        mode == CardMode.actionable &&
        occurrence != null &&
        await service.canMoveToNextDay(occurrence);
    if (!context.mounted) return;

    final choice = await showModalBottomSheet<_MenuChoice>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHeader(activity: entry.activity),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.actionEdit),
              onTap: () => Navigator.pop(context, _MenuChoice.edit),
            ),
            if (mode == CardMode.actionable)
              ListTile(
                enabled: canPostpone,
                leading: const Icon(Icons.redo_rounded),
                title: Text(l10n.actionPostpone),
                subtitle: canPostpone ? null : Text(l10n.cannotPostpone),
                onTap: () => Navigator.pop(context, _MenuChoice.postpone),
              ),
            ListTile(
              leading: const Icon(Icons.event_busy_outlined),
              title: Text(l10n.actionSkipDay),
              onTap: () => Navigator.pop(context, _MenuChoice.skipDay),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: context.tokens.danger),
              title: Text(
                l10n.actionDeleteActivity,
                style: TextStyle(color: context.tokens.danger),
              ),
              onTap: () => Navigator.pop(context, _MenuChoice.delete),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;

    switch (choice) {
      case _MenuChoice.edit:
        await context.push(Routes.editActivity(entry.activity.id));
      case _MenuChoice.postpone:
        final moved = await service.moveToNextDay(occurrence!.id);
        if (context.mounted) _toast(context, moved ? l10n.postponed : l10n.cannotPostpone);
      case _MenuChoice.skipDay:
        await service.skipDay(entry.activity.id, entry.date);
      case _MenuChoice.delete:
        if (await confirmDelete(context, entry.activity)) {
          await service.deleteActivity(entry.activity.id);
        }
    }
  }

  /// Asks confirmation before deleting the whole activity.
  static Future<bool> confirmDelete(BuildContext context, Activity activity) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(activity.name)),
        content: Text(l10n.deleteConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.tokens.danger),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  /// Percentage entry for partial activities.
  static Future<void> openProgress(BuildContext context, WidgetRef ref, DayEntry entry) async {
    final initial = entry.occurrence?.progress ?? 0;
    final value = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ProgressSheet(activity: entry.activity, initial: initial),
    );
    if (value == null) return;
    await ref.read(activityServiceProvider).setProgress(entry.activity.id, entry.date, value);
  }

  /// Decision sheet for a single missed occurrence.
  static Future<void> resolveMissed(
    BuildContext context,
    WidgetRef ref,
    Occurrence occurrence,
    Activity activity,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SheetHeader(activity: activity, date: occurrence.date),
              const SizedBox(height: 4),
              Text(
                context.l10n.missedPromptSubtitle,
                style: TextStyle(color: context.tokens.textMuted),
              ),
              const SizedBox(height: 12),
              MissedActions(occurrence: occurrence, onDone: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }

  /// Sheet listing every missed occurrence waiting for a decision.
  static Future<void> showMissedPrompt(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _MissedPromptSheet(),
    );
  }
}

enum _MenuChoice { edit, postpone, skipDay, delete }

/// Title of a sheet: color dot, activity name and optional date.
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.activity, this.date});

  final Activity activity;
  final LocalDate? date;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: YooPalettes.borderColor(activity.borderColorIndex),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              activity.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (date != null) Text(context.dayMonth(date!), style: TextStyle(color: t.textMuted)),
        ],
      ),
    );
  }
}

/// The three choices for a missed occurrence: done, move, leave.
class MissedActions extends ConsumerWidget {
  const MissedActions({super.key, required this.occurrence, this.onDone});

  final Occurrence occurrence;

  /// Called after an action has been applied.
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final service = ref.read(activityServiceProvider);
    return FutureBuilder<bool>(
      future: service.canMoveToNextDay(occurrence),
      builder: (context, snapshot) {
        final canMove = snapshot.data ?? false;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: t.success,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(l10n.missedDidIt),
              onPressed: () async {
                await service.completeRetroactively(occurrence.id);
                onDone?.call();
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.redo_rounded, size: 18),
              label: Text(canMove ? l10n.missedMoveToday : l10n.missedCannotMove),
              onPressed: canMove
                  ? () async {
                      await service.moveToNextDay(occurrence.id);
                      onDone?.call();
                    }
                  : null,
            ),
            TextButton(
              onPressed: () async {
                await service.leaveIncomplete(occurrence.id);
                onDone?.call();
              },
              child: Text(l10n.missedLeave),
            ),
          ],
        );
      },
    );
  }
}

class _MissedPromptSheet extends ConsumerWidget {
  const _MissedPromptSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final missed = ref.watch(unresolvedMissedProvider).value ?? const [];
    final activities = ref.watch(activitiesByIdProvider).value ?? const {};
    final items = [
      for (final o in missed)
        if (activities[o.activityId] != null) (o, activities[o.activityId]!),
    ]..sort((a, b) => b.$1.date.compareTo(a.$1.date));

    // Close by itself once everything has been decided.
    if (items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
    }

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(l10n.missedPromptTitle, style: Theme.of(context).textTheme.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(l10n.missedPromptSubtitle, style: TextStyle(color: t.textMuted)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final (occurrence, activity) in items)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        key: ValueKey(occurrence.id),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(t.radius),
                          border: Border.all(
                            color: YooPalettes.borderColor(activity.borderColorIndex),
                            width: t.cardBorderWidth,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SheetHeader(activity: activity, date: occurrence.date),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: MissedActions(occurrence: occurrence),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.missedResolveAll),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSheet extends StatefulWidget {
  const _ProgressSheet({required this.activity, required this.initial});

  final Activity activity;
  final int initial;

  @override
  State<_ProgressSheet> createState() => _ProgressSheetState();
}

class _ProgressSheetState extends State<_ProgressSheet> {
  late double _value = widget.initial.toDouble();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = YooPalettes.borderColor(widget.activity.borderColorIndex);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.activity.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.progressTitle, style: TextStyle(color: context.tokens.textMuted)),
            const SizedBox(height: 16),
            Center(
              child: Text(
                l10n.percent(_value.round()),
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Slider(
              value: _value,
              max: 100,
              divisions: 20,
              activeColor: color,
              onChanged: (v) => setState(() => _value = v),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                for (final quick in const [25, 50, 75, 100])
                  ChoiceChip(
                    label: Text(l10n.percent(quick)),
                    selected: _value.round() == quick,
                    onSelected: (_) => setState(() => _value = quick.toDouble()),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context, _value.round()),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
