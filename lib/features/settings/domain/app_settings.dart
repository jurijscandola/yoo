/// User-level preferences of the app.
///
/// Pure Dart: colors are stored as ARGB integers so that the domain layer does
/// not depend on Flutter. The presentation layer maps them to design tokens.
class AppSettings {
  const AppSettings({
    this.localeCode,
    this.theme = const ThemeConfig(),
  });

  /// Selected UI language (`en`, `it`). `null` means the user has not chosen yet,
  /// which triggers the first-launch language prompt.
  final String? localeCode;

  /// User-customized theme values.
  final ThemeConfig theme;

  /// Whether the first-launch language prompt must be shown.
  bool get needsLanguageChoice => localeCode == null;

  AppSettings copyWith({String? localeCode, ThemeConfig? theme}) {
    return AppSettings(
      localeCode: localeCode ?? this.localeCode,
      theme: theme ?? this.theme,
    );
  }
}

/// Every color and font of the app, as chosen by the user.
///
/// A `null` value means "use the default of the selected preset".
class ThemeConfig {
  const ThemeConfig({
    this.presetId = 'paper',
    this.pageColor,
    this.surfaceColor,
    this.navBarColor,
    this.cardColor,
    this.textColor,
    this.accentColor,
    this.notificationColor,
    this.fontFamily,
  });

  /// Identifier of the base preset the overrides are applied on.
  final String presetId;

  /// Page background.
  final int? pageColor;

  /// Day header rectangle and other raised surfaces.
  final int? surfaceColor;

  /// Bottom navigation bar background (defaults to [surfaceColor]).
  final int? navBarColor;

  /// Activity card fill (defaults to [surfaceColor]).
  final int? cardColor;

  /// Main text color.
  final int? textColor;

  /// Accent used by buttons and highlights.
  final int? accentColor;

  /// Accent color of notifications (Android only, iOS does not allow it).
  final int? notificationColor;

  /// Font family name; `null` uses the preset font.
  final String? fontFamily;

  /// Serializes to a plain map (used by persistence).
  Map<String, Object?> toJson() => {
    'presetId': presetId,
    'pageColor': pageColor,
    'surfaceColor': surfaceColor,
    'navBarColor': navBarColor,
    'cardColor': cardColor,
    'textColor': textColor,
    'accentColor': accentColor,
    'notificationColor': notificationColor,
    'fontFamily': fontFamily,
  };

  /// Restores a config serialized with [toJson]; unknown keys are ignored.
  factory ThemeConfig.fromJson(Map<String, Object?> json) => ThemeConfig(
    presetId: json['presetId'] as String? ?? 'paper',
    pageColor: json['pageColor'] as int?,
    surfaceColor: json['surfaceColor'] as int?,
    navBarColor: json['navBarColor'] as int?,
    cardColor: json['cardColor'] as int?,
    textColor: json['textColor'] as int?,
    accentColor: json['accentColor'] as int?,
    notificationColor: json['notificationColor'] as int?,
    fontFamily: json['fontFamily'] as String?,
  );
}
