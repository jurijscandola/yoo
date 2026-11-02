import 'package:flutter/material.dart';

/// An app icon of Yoo: the "Y" on a solid or gradient background.
///
/// The launcher icons are generated from the same values by
/// `tool/generate_icons.py` (keep the colors in sync); [YooIcon] draws them in
/// the app (splash, language prompt, icon picker).
class AppIconOption {
  const AppIconOption(this.id, this.background, this.foreground, [this.gradientEnd]);

  final String id;
  final Color background;
  final Color foreground;

  /// Second gradient color (top-left to bottom-right), if any.
  final Color? gradientEnd;

  static const all = [
    AppIconOption('classic', Color(0xFF1E1D1B), Color(0xFFFAF8F4)),
    AppIconOption('light', Color(0xFFFAF8F4), Color(0xFF1E1D1B)),
    AppIconOption('dark', Color(0xFF111112), Color(0xFF7DA7E0)),
    AppIconOption('ocean', Color(0xFF0090FF), Color(0xFFFFFFFF), Color(0xFF12A594)),
    AppIconOption('forest', Color(0xFF4F7A4A), Color(0xFFFFFFFF), Color(0xFF1E2A1E)),
    AppIconOption('sunset', Color(0xFFF76B15), Color(0xFFFFFFFF), Color(0xFFD6409F)),
  ];

  static AppIconOption byId(String id) =>
      all.firstWhere((o) => o.id == id, orElse: () => all.first);
}

/// Draws an [AppIconOption] as the launcher shows it.
class YooIcon extends StatelessWidget {
  const YooIcon({
    super.key,
    required this.option,
    this.size = 72,
    this.cornerShare = defaultCornerShare,
    this.shadow = false,
  });

  final AppIconOption option;
  final double size;

  /// Corner radius as a share of [size]: from a square (0) to a circle (0.5).
  final double cornerShare;

  /// A soft shadow, so light icons stand out on light pages.
  final bool shadow;

  /// Corner radius of the icon in the app, relative to the size.
  static const defaultCornerShare = 0.26;

  @override
  Widget build(BuildContext context) {
    final radius = size * cornerShare.clamp(0, 0.5);
    final icon = CustomPaint(
      size: Size.square(size),
      painter: _YooIconPainter(option: option, radius: radius),
    );
    if (!shadow) return icon;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: size * 0.1)],
      ),
      child: icon,
    );
  }
}

class _YooIconPainter extends CustomPainter {
  _YooIconPainter({required this.option, required this.radius});

  final AppIconOption option;
  final double radius;

  /// The "Y" in a 24×24 viewport, glyph box x 4–20, y 3–21 (same polygon as
  /// the notification icon and the launcher icons).
  static const _glyph = [
    Offset(4, 3),
    Offset(8.6, 3),
    Offset(12, 8.9),
    Offset(15.4, 3),
    Offset(20, 3),
    Offset(14, 12.9),
    Offset(14, 21),
    Offset(10, 21),
    Offset(10, 12.9),
  ];

  /// Share of the icon taken by the glyph's height: 40 of the 72 dp an
  /// Android adaptive icon shows.
  static const _glyphShare = 40 / 72;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final end = option.gradientEnd;
    final background = Paint()
      ..isAntiAlias = true
      ..color = option.background;
    if (end != null) {
      background.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [option.background, end],
      ).createShader(rect);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), background);

    final scale = size.height * _glyphShare / 18; // the glyph is 18 units tall
    final center = rect.center;
    final path = Path()
      ..addPolygon([
        for (final p in _glyph) center + Offset((p.dx - 12) * scale, (p.dy - 12) * scale),
      ], true);
    canvas.drawPath(
      path,
      Paint()
        ..isAntiAlias = true
        ..color = option.foreground,
    );
  }

  @override
  bool shouldRepaint(_YooIconPainter old) => old.option != option || old.radius != radius;
}
