import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/yoo_tokens.dart';
import '../../core/widgets/goals_bag_icon.dart';
import '../../l10n/l10n.dart';

/// Root layout with the bottom navigation bar (Calendar · Home · Goals).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell, required this.children});

  final StatefulNavigationShell navigationShell;

  /// One navigator per branch, provided by the shell route.
  final List<Widget> children;

  void _onTap(int index) {
    // Tapping the active tab returns it to its root route.
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: _FadeIndexedStack(index: navigationShell.currentIndex, children: children),
      bottomNavigationBar: YooNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        items: [
          YooNavItem(
            label: l10n.navCalendar,
            icon: (color) => Icon(Icons.calendar_month_outlined, color: color),
          ),
          YooNavItem(
            label: l10n.navHome,
            icon: (color) => Icon(Icons.home_outlined, color: color),
          ),
          YooNavItem(
            label: l10n.navGoals,
            icon: (color) => GoalsBagIcon(color: color),
          ),
        ],
      ),
    );
  }
}

/// Keeps every tab alive (like [IndexedStack]) and cross-fades between them.
class _FadeIndexedStack extends StatefulWidget {
  const _FadeIndexedStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<_FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<_FadeIndexedStack> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: 1,
  );

  @override
  void didUpdateWidget(covariant _FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.015), end: Offset.zero).animate(curved),
        child: IndexedStack(index: widget.index, children: widget.children),
      ),
    );
  }
}

/// Description of a navigation bar entry.
class YooNavItem {
  const YooNavItem({required this.label, required this.icon});

  final String label;

  /// Builds the icon with the given color (selected or not).
  final Widget Function(Color color) icon;
}

/// Minimal bottom navigation bar colored with the `navBar` token, with an
/// animated pill behind the selected item.
class YooNavBar extends StatelessWidget {
  const YooNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<YooNavItem> items;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: t.navBar,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final YooNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = selected ? t.text : t.textMuted;
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? t.text.withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: selected ? 1.1 : 1,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutBack,
                  child: item.icon(color),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 240),
                  style: TextStyle(
                    fontFamily: t.fontFamily,
                    fontSize: 11,
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  child: ExcludeSemantics(child: Text(item.label)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
