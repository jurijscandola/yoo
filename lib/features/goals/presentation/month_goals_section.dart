import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../core/time/date_labels.dart';
import '../../../core/widgets/raised_surface.dart';
import '../../../l10n/l10n.dart';
import '../../settings/domain/app_settings.dart';
import '../domain/goal_service.dart';
import '../domain/monthly_goal.dart';
import 'goal_actions.dart';
import 'goal_editor.dart';
import 'goal_providers.dart';

/// The goals of a month with their live progress, plus the button to add
/// one (current and future months only). Tapping a goal opens its actions.
class MonthGoalsSection extends ConsumerWidget {
  const MonthGoalsSection({super.key, required this.year, required this.month});

  final int year;
  final int month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final today = ref.watch(todayProvider);
    final canAdd = year > today.year || (year == today.year && month >= today.month);
    final goals = ref.watch(monthGoalsProgressProvider((year, month))).value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.calendarGoalsTitle(context.monthYear(year, month)),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (canAdd)
                IconButton.filledTonal(
                  tooltip: l10n.goalAdd,
                  icon: const Icon(Icons.add),
                  onPressed: () => GoalEditor.create(context, ref, year, month),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (goals != null && goals.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(t.radius),
              ),
              child: Column(
                children: [
                  Text(l10n.goalsEmptyMonth, style: TextStyle(color: t.text)),
                  if (canAdd) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.goalsEmptyMonthHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: t.textMuted, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          for (final g in goals ?? const <GoalProgress>[])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _GoalCard(progress: g, onTap: () => GoalActions.open(context, ref, g)),
            ),
        ],
      ),
    );
  }
}

/// A goal with its reached amount ("3 / 4"), an animated progress bar and,
/// once decided, its outcome (completed by hand, moved, not reached).
class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.progress, required this.onTap});

  final GoalProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final goal = progress.goal;
    final value = progress.fraction;
    final reached = progress.isReached;
    final moved = goal.outcome == GoalOutcome.moved;
    final color = reached
        ? t.success
        : moved || goal.outcome == GoalOutcome.leftIncomplete
        ? t.textMuted
        : t.accent;
    final movedTo = goal.movedTo;
    final fromId = goal.movedFromId;
    final from = fromId == null ? null : ref.watch(goalByIdProvider(fromId)).value;
    final status = [
      if (from != null) l10n.goalMovedFrom(context.monthYear(from.year, from.month)),
      if (movedTo != null) l10n.goalOutcomeMoved(context.monthYear(movedTo.$1, movedTo.$2)),
      if (goal.outcome == GoalOutcome.leftIncomplete) l10n.goalOutcomeLeft,
    ];
    // Paper style: a ruled notebook line instead of a card.
    final radius = t.cardStyle == CardStyle.paper
        ? BorderRadius.zero
        : BorderRadius.circular(t.radius);
    return Opacity(
      opacity: moved ? 0.7 : 1,
      child: RaisedSurface(
        color: t.surface,
        borderRadius: radius,
        accent: color,
        bordered: false,
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (reached) ...[
                        Icon(
                          goal.outcome == GoalOutcome.completed
                              ? Icons.check_circle_rounded
                              : Icons.emoji_events_rounded,
                          color: t.success,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          goal.title,
                          style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        goal.outcome == GoalOutcome.completed
                            ? l10n.goalOutcomeCompleted
                            : reached
                            ? l10n.goalReachedLabel
                            : l10n.goalAmount(progress.reached, goal.target),
                        style: TextStyle(color: color, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(status.join(' · '), style: TextStyle(color: t.textMuted, fontSize: 13)),
                  ],
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: value.toDouble()),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: v,
                        minHeight: 8,
                        color: color,
                        backgroundColor: t.divider,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
