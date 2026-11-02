import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../core/time/date_labels.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/l10n.dart';
import '../domain/goal_service.dart';
import 'goal_actions.dart';
import 'goal_providers.dart';
import 'month_goals_section.dart';

/// Page of the current month in the pager; earlier months are to the left.
const _currentPage = 10000;

/// Monthly goals, opened from the Goals tab: one month at a time (swipe or
/// arrows, tap the month to come back to this one). Above, a banner opens the
/// goals of months already over that wait for a decision.
class MonthlyGoalsScreen extends ConsumerStatefulWidget {
  const MonthlyGoalsScreen({super.key});

  @override
  ConsumerState<MonthlyGoalsScreen> createState() => _MonthlyGoalsScreenState();
}

class _MonthlyGoalsScreenState extends ConsumerState<MonthlyGoalsScreen> {
  final _pager = PageController(initialPage: _currentPage);
  int _page = _currentPage;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  LocalDate _monthOf(LocalDate today, int page) =>
      today.firstOfMonth.addMonths(page - _currentPage);

  void _goTo(int page) => _pager.animateToPage(
    page,
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final today = ref.watch(todayProvider);
    final month = _monthOf(today, _page);
    final toDecide = ref.watch(goalsToDecideProvider).value ?? const <GoalProgress>[];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.monthlyGoalsTitle)),
      body: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: toDecide.isEmpty
                ? const SizedBox(width: double.infinity)
                : _ToDecideBanner(count: toDecide.length),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Material(
              color: t.surface,
              borderRadius: BorderRadius.circular(t.radius),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.previousMonth,
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _goTo(_page - 1),
                  ),
                  Expanded(
                    child: Semantics(
                      button: _page != _currentPage,
                      hint: _page != _currentPage ? l10n.monthlyGoalsBackToCurrent : null,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(t.radius),
                        onTap: _page == _currentPage ? null : () => _goTo(_currentPage),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            context.monthYear(month.year, month.month),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.nextMonth,
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _goTo(_page + 1),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pager,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, page) {
                final m = _monthOf(today, page);
                return ListView(
                  key: ValueKey(m),
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [MonthGoalsSection(year: m.year, month: m.month, showMonth: false)],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// "3 goals to decide": opens the goals of months already over that were
/// not reached.
class _ToDecideBanner extends StatelessWidget {
  const _ToDecideBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Material(
        color: t.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(t.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(t.radius),
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) => const _ToDecideSheet(),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.flag_outlined, color: t.danger, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.monthlyGoalsToDecide(count),
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

/// Goals of months already over that were not reached, each with the three
/// choices; tapping a goal opens all its actions. Closes once all are
/// decided.
class _ToDecideSheet extends ConsumerWidget {
  const _ToDecideSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final goals = ref.watch(goalsToDecideProvider).value;
    if (goals != null && goals.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
    }
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          children: [
            Text(
              l10n.goalsToDecide,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(l10n.goalsToDecideHint, style: TextStyle(color: t.textMuted)),
            for (final p in goals ?? const <GoalProgress>[])
              Padding(
                key: ValueKey(p.goal.id),
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(t.radius),
                      onTap: () => GoalActions.open(context, ref, p),
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
                        ],
                      ),
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
