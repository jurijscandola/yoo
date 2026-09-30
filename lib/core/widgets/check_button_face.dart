import 'package:flutter/material.dart';

import '../../features/settings/domain/app_settings.dart';
import '../theme/yoo_tokens.dart';

/// The completion button of an activity, drawn in the activity's [color]: an
/// empty colored ring with a light tint, filled with a check when [done]. With
/// the paper card style it is a small square, like a checkbox on a notebook.
///
/// Until done it shows no check (it would read as "already done"); partial
/// activities show a "%" to say they are completed by percentage.
///
/// Visual only; the card wraps it with the tap handling. Also used by the
/// previews in the activity form and in Personalization.
class CheckButtonFace extends StatelessWidget {
  const CheckButtonFace({
    super.key,
    required this.color,
    this.done = false,
    this.partial = false,
    this.size = 34,
  });

  final Color color;
  final bool done;

  /// Partial activities show a "%" instead of a check.
  final bool partial;
  final double size;

  @override
  Widget build(BuildContext context) {
    final square = context.tokens.cardStyle == CardStyle.paper;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: square ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: square ? BorderRadius.circular(size * 0.2) : null,
        color: done ? color : color.withValues(alpha: 0.07),
        border: Border.all(color: color, width: 1.5),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
        child: done
            ? Icon(
                Icons.check_rounded,
                key: const ValueKey('done'),
                size: size * 0.59,
                color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              )
            : partial
            ? Icon(
                Icons.percent_rounded,
                key: const ValueKey('todo'),
                size: size * 0.53,
                color: color.withValues(alpha: 0.6),
              )
            : const SizedBox.shrink(key: ValueKey('todo')),
      ),
    );
  }
}
