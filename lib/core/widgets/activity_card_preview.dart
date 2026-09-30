import 'package:flutter/material.dart';

import '../../features/settings/domain/app_settings.dart';
import '../theme/yoo_tokens.dart';
import 'check_button_face.dart';
import 'raised_surface.dart';

/// A non-interactive activity card drawn with the current card style: used
/// by the activity form and the Personalization preview.
class ActivityCardPreview extends StatelessWidget {
  const ActivityCardPreview({
    super.key,
    required this.name,
    required this.color,
    this.partial = false,
    this.compact = false,
  });

  /// The activity name (usually a [Text], sized with the activity text
  /// scale by the caller).
  final Widget name;
  final Color color;
  final bool partial;

  /// Smaller paddings and button, for the mock screen in Personalization.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    if (t.cardStyle == CardStyle.paper) {
      return RaisedSurface(
        color: t.card,
        borderRadius: BorderRadius.zero,
        accent: color,
        paperMargin: true,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, compact ? 8 : 12, 10, compact ? 8 : 12),
          child: Row(
            children: [
              SizedBox(
                width: RaisedSurface.paperMarginWidth,
                child: Center(
                  child: CheckButtonFace(color: color, partial: partial, size: compact ? 18 : 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: name),
            ],
          ),
        ),
      );
    }
    return RaisedSurface(
      color: t.card,
      borderRadius: BorderRadius.circular(compact ? t.radius * 0.6 : t.radius),
      accent: color,
      borderWidth: t.cardBorderWidth,
      child: Padding(
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
            : const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            CheckButtonFace(color: color, partial: partial, size: compact ? 17 : 26),
            SizedBox(width: compact ? 10 : 14),
            Expanded(child: name),
          ],
        ),
      ),
    );
  }
}
