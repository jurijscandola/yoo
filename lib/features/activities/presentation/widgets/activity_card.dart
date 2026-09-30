import 'package:flutter/material.dart';

import '../../../../core/theme/yoo_palettes.dart';
import '../../../../core/theme/yoo_tokens.dart';
import '../../../../core/widgets/check_button_face.dart';
import '../../../../core/widgets/raised_surface.dart';
import '../../../../l10n/l10n.dart';
import '../../../settings/domain/app_settings.dart';
import '../../domain/entities/occurrence.dart';
import '../../domain/services/occurrence_planner.dart';
import 'subtask_list.dart';

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
/// check button fills with an animation before the card leaves the list. The
/// arrow next to "⋯" expands the activity's subtasks.
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
  bool _expanded = false;

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
    // Paper style: a notebook line instead of a card, with the completion
    // square in the left margin; the other buttons stay on the right.
    final paper = t.cardStyle == CardStyle.paper;
    final radius = paper ? BorderRadius.zero : BorderRadius.circular(t.radius);
    final scale = t.activityTextScale;
    final nameStyle = Theme.of(context).textTheme.titleMedium;

    // The completion button sits on the left in every style. On days that
    // cannot be ticked a faded one keeps the names aligned.
    final buttonSize = paper ? 22.0 : 26.0;
    final Widget button = widget.mode == CardMode.actionable
        ? _CheckButton(
            color: border,
            done: _completing,
            partial: activity.isPartial,
            size: buttonSize,
            onPressed: _press,
          )
        : Opacity(
            opacity: 0.35,
            child: CheckButtonFace(color: border, partial: activity.isPartial, size: buttonSize),
          );

    return Padding(
      padding: paper ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: dimmed ? 0.75 : 1,
        child: RaisedSurface(
          color: t.card,
          borderRadius: radius,
          accent: border,
          borderWidth: t.cardBorderWidth,
          paperMargin: true,
          child: Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: radius),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                InkWell(
                  onTap: widget.onTap,
                  onLongPress: widget.onMenu,
                  child: Column(
                    children: [
                      Padding(
                        padding: paper
                            ? const EdgeInsets.fromLTRB(0, 8, 4, 8)
                            : const EdgeInsets.fromLTRB(10, 12, 4, 12),
                        child: Row(
                          children: [
                            if (paper) ...[
                              SizedBox(
                                width: RaisedSurface.paperMarginWidth,
                                child: Center(child: button),
                              ),
                              const SizedBox(width: 12),
                            ] else ...[
                              button,
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.name,
                                    style: nameStyle?.copyWith(
                                      fontSize: (nameStyle.fontSize ?? 16) * scale,
                                      fontWeight: FontWeight.w600,
                                      decoration: widget.mode == CardMode.missed
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor: t.danger,
                                    ),
                                  ),
                                  if (subtitle != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle,
                                      style: TextStyle(color: t.textMuted, fontSize: 13 * scale),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (widget.mode == CardMode.missed)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(Icons.close_rounded, color: t.danger),
                              ),
                            SubtaskToggle(
                              activityId: activity.id,
                              date: widget.entry.date,
                              expanded: _expanded,
                              onPressed: () => setState(() => _expanded = !_expanded),
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
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _expanded
                      ? SubtaskList(
                          activityId: activity.id,
                          date: widget.entry.date,
                          canCheck: widget.mode == CardMode.actionable,
                          color: border,
                        )
                      : const SizedBox(width: double.infinity),
                ),
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

/// Round check button in the activity's [color]; fills and shows a check
/// when [done].
class _CheckButton extends StatelessWidget {
  const _CheckButton({
    required this.color,
    required this.done,
    required this.partial,
    required this.onPressed,
    this.size = 26,
  });

  final Color color;
  final bool done;
  final bool partial;
  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.progressDone,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: CheckButtonFace(color: color, done: done, partial: partial, size: size),
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
