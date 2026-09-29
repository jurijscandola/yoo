import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../features/settings/domain/app_settings.dart';
import 'yoo_palettes.dart';

/// Design tokens of Yoo.
///
/// Every color, font and radius used by widgets must come from here (read it
/// with `context.tokens`), so that the whole UI follows the user's settings.
@immutable
class YooTokens extends ThemeExtension<YooTokens> {
  const YooTokens({
    required this.brightness,
    required this.page,
    required this.surface,
    required this.navBar,
    required this.card,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.danger,
    required this.notification,
    required this.divider,
    required this.fontFamily,
    this.radius = 16,
    this.cardBorderWidth = 2,
  });

  /// Whether the palette is light or dark (drives system UI overlays).
  final Brightness brightness;

  /// Page background.
  final Color page;

  /// Day header rectangle, sheets and dialogs.
  final Color surface;

  /// Bottom navigation bar background.
  final Color navBar;

  /// Activity card fill.
  final Color card;

  /// Main text.
  final Color text;

  /// Secondary text (hints, captions).
  final Color textMuted;

  /// Accent for primary actions (e.g. the "+" button).
  final Color accent;

  /// Content drawn on top of [accent].
  final Color onAccent;

  /// Completed state (green check).
  final Color success;

  /// Not-completed state and destructive actions (red cross).
  final Color danger;

  /// Notification accent color (Android).
  final Color notification;

  /// Hairlines and subtle separators.
  final Color divider;

  /// Font family; `null` uses the platform font.
  final String? fontFamily;

  /// Corner radius of cards and rectangles.
  final double radius;

  /// Width of the colored activity card border.
  final double cardBorderWidth;

  /// Builds the tokens from the user's [config] applied over its preset.
  factory YooTokens.fromConfig(ThemeConfig config) {
    final preset = YooPalettes.presetById(config.presetId);
    Color pick(int? value, Color fallback) => value == null ? fallback : Color(value);

    final surface = pick(config.surfaceColor, preset.surface);
    final text = pick(config.textColor, preset.text);
    final accent = pick(config.accentColor, preset.accent);
    return YooTokens(
      brightness: preset.brightness,
      page: pick(config.pageColor, preset.page),
      surface: surface,
      navBar: pick(config.navBarColor, surface),
      card: pick(config.cardColor, surface),
      text: text,
      textMuted: text.withValues(alpha: 0.55),
      accent: accent,
      onAccent: _contrastOn(accent),
      success: preset.success,
      danger: preset.danger,
      notification: pick(config.notificationColor, accent),
      divider: text.withValues(alpha: 0.08),
      fontFamily: config.fontFamily ?? preset.fontFamily,
    );
  }

  /// Picks black or white, whichever reads better on [background].
  static Color _contrastOn(Color background) =>
      background.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  @override
  YooTokens copyWith({
    Color? page,
    Color? surface,
    Color? navBar,
    Color? card,
    Color? text,
    Color? accent,
  }) {
    return YooTokens(
      brightness: brightness,
      page: page ?? this.page,
      surface: surface ?? this.surface,
      navBar: navBar ?? this.navBar,
      card: card ?? this.card,
      text: text ?? this.text,
      textMuted: textMuted,
      accent: accent ?? this.accent,
      onAccent: onAccent,
      success: success,
      danger: danger,
      notification: notification,
      divider: divider,
      fontFamily: fontFamily,
      radius: radius,
      cardBorderWidth: cardBorderWidth,
    );
  }

  /// Interpolates tokens so that theme changes animate smoothly.
  @override
  YooTokens lerp(YooTokens? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return YooTokens(
      brightness: t < 0.5 ? brightness : other.brightness,
      page: c(page, other.page),
      surface: c(surface, other.surface),
      navBar: c(navBar, other.navBar),
      card: c(card, other.card),
      text: c(text, other.text),
      textMuted: c(textMuted, other.textMuted),
      accent: c(accent, other.accent),
      onAccent: c(onAccent, other.onAccent),
      success: c(success, other.success),
      danger: c(danger, other.danger),
      notification: c(notification, other.notification),
      divider: c(divider, other.divider),
      fontFamily: t < 0.5 ? fontFamily : other.fontFamily,
      radius: lerpDouble(radius, other.radius, t)!,
      cardBorderWidth: lerpDouble(cardBorderWidth, other.cardBorderWidth, t)!,
    );
  }
}

/// Convenient access to the design tokens from any widget.
extension YooTokensContext on BuildContext {
  YooTokens get tokens => Theme.of(this).extension<YooTokens>()!;
}
