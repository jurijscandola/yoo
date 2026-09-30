import 'package:flutter/material.dart';

/// Line icon of a mountain peak with a flag on top, used for the Goals tab.
///
/// Material has no such glyph, so it is painted to match the outlined icons.
class GoalsIcon extends StatelessWidget {
  const GoalsIcon({super.key, this.size = 24, this.color});

  final double size;

  /// Stroke color; defaults to the ambient [IconTheme] color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? IconTheme.of(context).color ?? Colors.black;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _PeakPainter(resolved)),
    );
  }
}

class _PeakPainter extends CustomPainter {
  _PeakPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Main peak with a smaller shoulder on the right.
    final mountain = Path()
      ..moveTo(2.5 * s, 20 * s)
      ..lineTo(9.5 * s, 8.5 * s)
      ..lineTo(12.7 * s, 13.7 * s)
      ..lineTo(15 * s, 10.5 * s)
      ..lineTo(21.5 * s, 20 * s)
      ..close();
    canvas.drawPath(mountain, stroke);

    // Flag on the summit.
    final flag = Path()
      ..moveTo(9.5 * s, 8.5 * s)
      ..lineTo(9.5 * s, 3.5 * s)
      ..lineTo(13 * s, 4.9 * s)
      ..lineTo(9.5 * s, 6.3 * s);
    canvas.drawPath(flag, stroke);
  }

  @override
  bool shouldRepaint(_PeakPainter oldDelegate) => oldDelegate.color != color;
}
