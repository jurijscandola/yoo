import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../l10n/l10n.dart';
import 'goal_providers.dart';

/// Goals tab. For now the entry to the monthly goals (with how many wait for
/// a decision) and the settings menu; the rest of the page is free for what
/// comes next.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final toDecide = ref.watch(goalsToDecideProvider).value?.length ?? 0;
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Material(
            color: t.surface,
            borderRadius: BorderRadius.circular(t.radius),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Badge(
                isLabelVisible: toDecide > 0,
                backgroundColor: t.danger,
                child: Icon(Icons.calendar_view_month_rounded, color: t.accent),
              ),
              title: Text(
                l10n.monthlyGoalsTitle,
                style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                toDecide > 0 ? l10n.monthlyGoalsToDecide(toDecide) : l10n.monthlyGoalsSubtitle,
                style: TextStyle(color: toDecide > 0 ? t.danger : t.textMuted),
              ),
              trailing: Icon(Icons.chevron_right, color: t.textMuted),
              onTap: () => context.go(Routes.monthlyGoals),
            ),
          ),
        ],
      ),
    );
  }
}
