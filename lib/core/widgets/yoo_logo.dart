import 'package:flutter/material.dart';

import '../theme/yoo_tokens.dart';

/// Placeholder logo of Yoo.
///
/// Replace the body with an `Image.asset('assets/branding/logo.png')` once the
/// final artwork is provided; every usage goes through this widget.
class YooLogo extends StatelessWidget {
  const YooLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(size * 0.3)),
      alignment: Alignment.center,
      child: Text(
        'Y',
        style: TextStyle(
          color: t.onAccent,
          fontSize: size * 0.5,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
