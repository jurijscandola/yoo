import 'package:flutter/material.dart';

import '../../features/settings/domain/app_settings.dart';
import '../theme/yoo_tokens.dart';

/// Gives a card a subtle lift: a barely-there top highlight over [color], a
/// soft two-layer shadow (contact + ambient), and a slight "press in" while a
/// finger rests on it. Kept light so it sits well with the colored borders.
///
/// Border and shadow follow the user's [CardStyle]:
/// - standard: full [accent] border (when [bordered]) and a neutral shadow;
/// - coloredShadow: no border, a light shadow tinted by [accent] (the color
///   stays on the completion button);
/// - halfBorder: an [accent] border on the lower half only, fading upwards;
/// - onlyButton: no border and the neutral shadow (the color stays on the
///   completion button);
/// - paper: no card at all, just a ruled notebook line under the content and,
///   with [paperMargin], the red margin line on the left.
///
/// The [child] should be a transparent [Material] so ripples still show.
class RaisedSurface extends StatefulWidget {
  const RaisedSurface({
    super.key,
    required this.color,
    required this.borderRadius,
    required this.accent,
    required this.child,
    this.bordered = true,
    this.borderWidth = 2,
    this.paperMargin = false,
  });

  /// Width of the notebook margin (paper style); the completion square sits
  /// in it, the text starts after the margin line.
  static const paperMarginWidth = 52.0;

  /// Fill of the card.
  final Color color;
  final BorderRadius borderRadius;

  /// The card's own color (activity border, goal progress color).
  final Color accent;

  /// Whether the standard styles draw a full border (goal cards have none).
  final bool bordered;
  final double borderWidth;

  /// Whether the paper style draws the margin line (activity rows).
  final bool paperMargin;
  final Widget child;

  @override
  State<RaisedSurface> createState() => _RaisedSurfaceState();
}

class _RaisedSurfaceState extends State<RaisedSurface> {
  /// Moving further than this means a scroll or swipe, not a press.
  static const _slop = 8.0;

  bool _pressed = false;
  Offset? _downAt;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final dark = t.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final pressed = _pressed && !reduceMotion;
    final style = t.cardStyle;

    if (style == CardStyle.paper) {
      return CustomPaint(
        foregroundPainter: _PaperPainter(
          rule: _paperRule(dark),
          margin: widget.paperMargin ? _paperMarginLine(dark) : null,
        ),
        child: widget.child,
      );
    }

    final top = Color.lerp(widget.color, Colors.white, dark ? 0.03 : 0.2)!;
    final colored = style == CardStyle.coloredShadow;
    final (Color shadow, Color contact) = colored
        ? (
            widget.accent.withValues(alpha: dark ? 0.38 : 0.26),
            widget.accent.withValues(alpha: dark ? 0.18 : 0.1),
          )
        : (
            Colors.black.withValues(alpha: dark ? 0.28 : 0.06),
            Colors.black.withValues(alpha: dark ? 0.22 : 0.05),
          );
    final border = switch (style) {
      CardStyle.halfBorder => _Border.half,
      CardStyle.standard when widget.bordered => _Border.full,
      _ => _Border.none,
    };

    return Listener(
      onPointerDown: (e) {
        _downAt = e.position;
        _setPressed(true);
      },
      onPointerMove: (e) {
        final start = _downAt;
        if (start != null && (e.position - start).distance > _slop) _setPressed(false);
      },
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [top, widget.color],
              stops: const [0, 0.5],
            ),
            boxShadow: [
              BoxShadow(
                color: contact,
                offset: Offset(0, pressed ? 0.5 : 1),
                blurRadius: pressed ? 1 : 2,
              ),
              BoxShadow(
                color: shadow,
                // The colored glow reaches a bit further to be noticed.
                offset: Offset(0, pressed ? (colored ? 2 : 1) : (colored ? 6 : 3)),
                blurRadius: pressed ? (colored ? 10 : 4) : (colored ? 18 : 10),
                spreadRadius: colored ? -4 : -3,
              ),
            ],
          ),
          child: CustomPaint(
            foregroundPainter: border == _Border.none
                ? null
                : _BorderPainter(
                    color: widget.accent,
                    width: widget.borderWidth,
                    radius: widget.borderRadius,
                    half: border == _Border.half,
                  ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

enum _Border { none, full, half }

/// Blue ruling of a notebook page.
Color _paperRule(bool dark) => const Color(0xFF6E9BD1).withValues(alpha: dark ? 0.35 : 0.45);

/// Red margin line of a notebook page.
Color _paperMarginLine(bool dark) => const Color(0xFFD9606A).withValues(alpha: dark ? 0.5 : 0.55);

/// A ruled line along the bottom and, optionally, the vertical margin line.
class _PaperPainter extends CustomPainter {
  _PaperPainter({required this.rule, this.margin});

  final Color rule;
  final Color? margin;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = rule
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height - 0.5), Offset(size.width, size.height - 0.5), line);
    final m = margin;
    if (m != null) {
      const x = RaisedSurface.paperMarginWidth;
      canvas.drawLine(
        const Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = m
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(_PaperPainter old) => old.rule != rule || old.margin != margin;
}

/// Strokes the rounded outline, either solid or fading out towards the top.
class _BorderPainter extends CustomPainter {
  _BorderPainter({
    required this.color,
    required this.width,
    required this.radius,
    required this.half,
  });

  final Color color;
  final double width;
  final BorderRadius radius;
  final bool half;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    if (half) {
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0), color.withValues(alpha: 0), color, color],
        stops: const [0, 0.3, 0.6, 1],
      ).createShader(rect);
    } else {
      paint.color = color;
    }
    canvas.drawRRect(radius.toRRect(rect).deflate(width / 2), paint);
  }

  @override
  bool shouldRepaint(_BorderPainter old) =>
      old.color != color || old.width != width || old.radius != radius || old.half != half;
}
