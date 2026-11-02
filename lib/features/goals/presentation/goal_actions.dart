import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/services.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../core/time/date_labels.dart';
import '../../../l10n/l10n.dart';
import '../domain/goal_service.dart';
import '../domain/monthly_goal.dart';
import 'goal_editor.dart';

/// Actions on a goal, shared by the Goals tab and the calendar: mark it as
/// completed, move it to the next month, leave it, reopen it, edit it.
abstract final class GoalActions {
  /// Opens the actions available for [progress]. Goals with nothing to
  /// decide go straight to the editor.
  static Future<void> open(BuildContext context, WidgetRef ref, GoalProgress progress) async {
    final goal = progress.goal;
    final today = ref.read(todayProvider);
    final isFuture =
        goal.year > today.year || (goal.year == today.year && goal.month > today.month);
    final open = !goal.isResolved && !progress.isReached;
    final canMove = open && !isFuture;
    final canLeave = open && goal.isPastAt(today);
    final canReopen =
        goal.outcome == GoalOutcome.completed || goal.outcome == GoalOutcome.leftIncomplete;
    if (!open && !canReopen) return GoalEditor.edit(context, ref, goal);

    final l10n = context.l10n;
    final service = ref.read(goalServiceProvider);
    final (toYear, toMonth) = service.moveTargetFor(goal);
    final choice = await showModalBottomSheet<_Choice>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  goal.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (open)
                ListTile(
                  leading: Icon(Icons.check_circle_outline_rounded, color: context.tokens.success),
                  title: Text(l10n.goalMarkCompleted),
                  onTap: () => Navigator.pop(context, _Choice.complete),
                ),
              if (canMove)
                ListTile(
                  leading: const Icon(Icons.redo_rounded),
                  title: Text(l10n.goalMoveTo(context.monthYear(toYear, toMonth))),
                  subtitle: Text(l10n.goalMoveHint),
                  onTap: () => Navigator.pop(context, _Choice.move),
                ),
              if (canLeave)
                ListTile(
                  leading: const Icon(Icons.do_not_disturb_on_outlined),
                  title: Text(l10n.goalLeaveIncomplete),
                  onTap: () => Navigator.pop(context, _Choice.leave),
                ),
              if (canReopen)
                ListTile(
                  leading: const Icon(Icons.undo_rounded),
                  title: Text(l10n.goalReopen),
                  onTap: () => Navigator.pop(context, _Choice.reopen),
                ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.goalEdit),
                onTap: () => Navigator.pop(context, _Choice.edit),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    switch (choice) {
      case _Choice.complete:
        await service.markCompleted(goal);
      case _Choice.move:
        await moveToNextMonth(context, ref, goal);
      case _Choice.leave:
        await service.leaveIncomplete(goal);
      case _Choice.reopen:
        await service.reopen(goal);
      case _Choice.edit:
        await GoalEditor.edit(context, ref, goal);
    }
  }

  /// Moves [goal] to the next month and confirms it with a message.
  static Future<void> moveToNextMonth(BuildContext context, WidgetRef ref, MonthlyGoal goal) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final copy = await ref.read(goalServiceProvider).moveToNextMonth(goal);
    if (copy == null || !context.mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(l10n.goalOutcomeMoved(context.monthYear(copy.year, copy.month)))),
      );
  }
}

enum _Choice { complete, move, leave, reopen, edit }

/// The three choices for a goal whose month is over: completed, move, leave.
class GoalDecisionButtons extends ConsumerWidget {
  const GoalDecisionButtons({super.key, required this.goal});

  final MonthlyGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final service = ref.read(goalServiceProvider);
    final (toYear, toMonth) = service.moveTargetFor(goal);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: t.success, foregroundColor: Colors.white),
          icon: const Icon(Icons.check_rounded, size: 18),
          label: Text(l10n.goalMarkCompleted),
          onPressed: () => service.markCompleted(goal),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.redo_rounded, size: 18),
          label: Text(l10n.goalMoveTo(context.monthYear(toYear, toMonth))),
          onPressed: () => GoalActions.moveToNextMonth(context, ref, goal),
        ),
        TextButton(
          onPressed: () => service.leaveIncomplete(goal),
          child: Text(l10n.goalLeaveIncomplete),
        ),
      ],
    );
  }
}
