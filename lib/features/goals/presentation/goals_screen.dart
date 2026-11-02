import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../core/time/date_labels.dart';
import '../../../l10n/l10n.dart';
import '../domain/goal_service.dart';
import 'goal_actions.dart';
import 'goal_providers.dart';
import 'month_goals_section.dart';

/// Goals tab: the monthly summary. First the goals of months already over
/// that wait for a decision (completed, moved to the next month, or left),
/// then this month, the coming months and the past ones.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final today = ref.watch(todayProvider);
    final current = (today.year, today.month);
    final months = ref.watch(goalMonthsProvider).value ?? const <(int, int)>{};
    final toDecide = ref.watch(goalsToDecideProvider).value ?? const <GoalProgress>[];

    int compare((int, int) a, (int, int) b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2;
    final upcoming = months.where((m) => compare(m, current) > 0).toList()..sort(compare);
    final past = months.where((m) => compare(m, current) < 0).toList()
      ..sort((a, b) => compare(b, a));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.goalsTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: l10n.moreOptions,
            icon: const Icon(Icons.more_horiz),
            onPressed: () => context.push(Routes.settings),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: toDecide.isEmpty
                ? const SizedBox(width: double.infinity)
                : _ToDecideSection(goals: toDecide),
          ),
          MonthGoalsSection(year: current.$1, month: current.$2),
          for (final (year, month) in upcoming) MonthGoalsSection(year: year, month: month),
          if (past.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                l10n.goalsPast,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: t.textMuted, fontWeight: FontWeight.w600),
              ),
            ),
          for (final (year, month) in past) MonthGoalsSection(year: year, month: month),
        ],
      ),
    );
  }
}

/// Goals of months already over that were not reached, each with the three
/// choices.
class _ToDecideSection extends StatelessWidget {
  const _ToDecideSection({required this.goals});

  final List<GoalProgress> goals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        decoration: BoxDecoration(
          color: t.danger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(t.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.flag_outlined, color: t.danger, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.goalsToDecide,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(l10n.goalsToDecideHint, style: TextStyle(color: t.textMuted)),
            for (final p in goals)
              Padding(
                key: ValueKey(p.goal.id),
                padding: const EdgeInsets.only(top: 14, bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.goal.title,
                            style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          l10n.goalAmount(p.reached, p.goal.target),
                          style: TextStyle(color: t.textMuted, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Text(
                      context.monthYear(p.goal.year, p.goal.month),
                      style: TextStyle(color: t.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    GoalDecisionButtons(goal: p.goal),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
