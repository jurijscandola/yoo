import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../core/time/date_labels.dart';
import '../../../core/widgets/raised_surface.dart';
import '../../../l10n/l10n.dart';
import '../../settings/domain/app_settings.dart';
import '../domain/goal_service.dart';
import 'goal_editor.dart';
import 'goal_providers.dart';

/// The goals of a month with their live progress, plus the button to add
/// one (current and future months only). Tapping a goal edits it.
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
              child: _GoalCard(progress: g, onTap: () => GoalEditor.edit(context, ref, g.goal)),
            ),
        ],
      ),
    );
  }
}

/// A goal with its reached amount ("3 / 4") and an animated progress bar.
class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.progress, required this.onTap});

  final GoalProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final value = progress.fraction;
    final reached = progress.isReached;
    final color = reached ? t.success : t.accent;
    // Paper style: a ruled notebook line instead of a card.
    final radius = t.cardStyle == CardStyle.paper
        ? BorderRadius.zero
        : BorderRadius.circular(t.radius);
    return RaisedSurface(
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
                      Icon(Icons.emoji_events_rounded, color: t.success, size: 20),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        progress.goal.title,
                        style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      reached
                          ? l10n.goalReachedLabel
                          : l10n.goalAmount(progress.reached, progress.goal.target),
                      style: TextStyle(color: color, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
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
    );
  }
}
