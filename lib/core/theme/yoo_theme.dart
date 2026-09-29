import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'yoo_tokens.dart';

/// Builds the Material [ThemeData] from the design tokens.
///
/// Material widgets are themed here so that screens rarely need to read raw
/// colors; custom widgets read [YooTokens] via `context.tokens`.
abstract final class YooTheme {
  static ThemeData build(YooTokens t) {
    final scheme = ColorScheme.fromSeed(
      seedColor: t.accent,
      brightness: t.brightness,
    ).copyWith(
      primary: t.accent,
      onPrimary: t.onAccent,
      surface: t.surface,
      onSurface: t.text,
      error: t.danger,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: t.brightness,
      colorScheme: scheme,
      fontFamily: t.fontFamily,
      scaffoldBackgroundColor: t.page,
      canvasColor: t.page,
      dividerColor: t.divider,
      splashFactory: InkSparkle.splashFactory,
      extensions: [t],
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: t.text,
        displayColor: t.text,
        fontFamily: t.fontFamily,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.page,
        foregroundColor: t.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: t.accent,
        foregroundColor: t.onAccent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radius + 4),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surface,
        showDragHandle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(t.radius),
          borderSide: BorderSide.none,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
