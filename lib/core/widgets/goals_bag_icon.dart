import 'package:flutter/material.dart';

/// Line icon of a bag with an upward arrow, used for the Goals tab.
///
/// Material has no such glyph, so it is painted to match the outlined icons.
class GoalsBagIcon extends StatelessWidget {
  const GoalsBagIcon({super.key, this.size = 24, this.color});

  final double size;

  /// Stroke color; defaults to the ambient [IconTheme] color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? IconTheme.of(context).color ?? Colors.black;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _BagPainter(resolved)),
    );
  }
}

class _BagPainter extends CustomPainter {
  _BagPainter(this.color);

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

    // Bag body.
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(4 * s, 8 * s, 20 * s, 21 * s),
      Radius.circular(3 * s),
    );
    canvas.drawRRect(body, stroke);

    // Handle.
    final handle = Path()
      ..moveTo(8.5 * s, 8 * s)
      ..lineTo(8.5 * s, 6.5 * s)
      ..arcToPoint(Offset(15.5 * s, 6.5 * s), radius: Radius.circular(3.5 * s))
      ..lineTo(15.5 * s, 8 * s);
    canvas.drawPath(handle, stroke);

    // Upward arrow.
    canvas.drawLine(Offset(12 * s, 18 * s), Offset(12 * s, 11.5 * s), stroke);
    final head = Path()
      ..moveTo(9.5 * s, 14 * s)
      ..lineTo(12 * s, 11.5 * s)
      ..lineTo(14.5 * s, 14 * s);
    canvas.drawPath(head, stroke);
  }

  @override
  bool shouldRepaint(_BagPainter oldDelegate) => oldDelegate.color != color;
}
