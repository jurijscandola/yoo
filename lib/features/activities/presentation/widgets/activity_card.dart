import 'package:flutter/material.dart';

import '../../../../core/theme/yoo_palettes.dart';
import '../../../../core/theme/yoo_tokens.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/occurrence.dart';
import '../../domain/services/occurrence_planner.dart';

/// How a card can be interacted with, depending on the day it belongs to.
enum CardMode {
  /// Today: can be completed.
  actionable,

  /// A future day: read-only preview.
  preview,

  /// A past day: missed, waiting for a decision.
  missed,
}

/// Rectangular card of an activity on a day.
///
/// Filled with the `card` token, bordered with the activity's color. The
/// check button fills with an animation before the card leaves the list.
class ActivityCard extends StatefulWidget {
  const ActivityCard({
    super.key,
    required this.entry,
    required this.mode,
    this.onComplete,
    this.onMenu,
    this.onTap,
  });

  final DayEntry entry;
  final CardMode mode;

  /// Called when the check button is pressed (after its animation when the
  /// press completes the activity).
  final Future<void> Function()? onComplete;

  /// Opens the actions menu (long press or "⋯").
  final VoidCallback? onMenu;

  /// Tap on the card body.
  final VoidCallback? onTap;

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  bool _completing = false;

  Occurrence? get _occurrence => widget.entry.occurrence;

  /// Whether the next press finishes the activity (so the check animates).
  bool get _nextPressCompletes {
    final activity = widget.entry.activity;
    if (activity.isPartial) return false;
    return (_occurrence?.completedCount ?? 0) + 1 >= activity.timesPerDay;
  }

  Future<void> _press() async {
    if (_completing || widget.onComplete == null) return;
    if (_nextPressCompletes) {
      setState(() => _completing = true);
      await Future<void>.delayed(const Duration(milliseconds: 380));
    }
    await widget.onComplete!();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final activity = widget.entry.activity;
    final border = YooPalettes.borderColor(activity.borderColorIndex);
    final subtitle = _subtitle(context);
    final dimmed = widget.mode == CardMode.preview;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: dimmed ? 0.75 : 1,
        child: Material(
          color: t.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(t.radius),
            side: BorderSide(color: border, width: t.cardBorderWidth),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: widget.onMenu,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: widget.mode == CardMode.missed
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: t.danger,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(subtitle, style: TextStyle(color: t.textMuted, fontSize: 13)),
                            ],
                          ],
                        ),
                      ),
                      if (widget.mode == CardMode.actionable)
                        _CheckButton(
                          color: border,
                          done: _completing,
                          partial: activity.isPartial,
                          onPressed: _press,
                        ),
                      if (widget.mode == CardMode.missed)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(Icons.close_rounded, color: t.danger),
                        ),
                      if (widget.onMenu != null)
                        IconButton(
                          tooltip: context.l10n.moreOptions,
                          icon: Icon(Icons.more_vert, color: t.textMuted),
                          onPressed: widget.onMenu,
                        ),
                    ],
                  ),
                ),
                if (activity.isPartial)
                  _ProgressLine(value: (_occurrence?.progress ?? 0) / 100, color: border),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _subtitle(BuildContext context) {
    final activity = widget.entry.activity;
    final l10n = context.l10n;
    final o = _occurrence;
    if (activity.isPartial) return l10n.percent(o?.progress ?? 0);
    if (activity.timesPerDay > 1) {
      return l10n.timesDone(o?.completedCount ?? 0, activity.timesPerDay);
    }
    return null;
  }
}

/// Round check button; fills with [color] and shows a check when [done].
class _CheckButton extends StatelessWidget {
  const _CheckButton({
    required this.color,
    required this.done,
    required this.partial,
    required this.onPressed,
  });

  final Color color;
  final bool done;
  final bool partial;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: context.l10n.progressDone,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutBack,
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? color : Colors.transparent,
              border: Border.all(color: color, width: 2),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
              child: done
                  ? Icon(
                      Icons.check_rounded,
                      key: const ValueKey('done'),
                      size: 20,
                      color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    )
                  : Icon(
                      partial ? Icons.percent_rounded : Icons.check_rounded,
                      key: const ValueKey('todo'),
                      size: 18,
                      color: t.textMuted.withValues(alpha: 0.35),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin animated progress line at the bottom of partial cards.
class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => LinearProgressIndicator(
        value: v,
        minHeight: 3,
        color: color,
        backgroundColor: color.withValues(alpha: 0.12),
      ),
    );
  }
}
