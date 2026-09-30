/// User-level preferences of the app.
///
/// Pure Dart: colors are stored as ARGB integers so that the domain layer does
/// not depend on Flutter. The presentation layer maps them to design tokens.
class AppSettings {
  const AppSettings({
    this.localeCode,
    this.theme = const ThemeConfig(),
    this.externalCalendars = const ExternalCalendarSettings(),
    this.appIconId = defaultAppIconId,
  });

  /// Identifier of the app icon chosen in Personalization.
  static const defaultAppIconId = 'classic';

  /// Selected UI language (`en`, `it`). `null` means the user has not chosen yet,
  /// which triggers the first-launch language prompt.
  final String? localeCode;

  /// User-customized theme values.
  final ThemeConfig theme;

  /// Which device calendars are shown next to the activities.
  final ExternalCalendarSettings externalCalendars;

  /// App icon chosen by the user (previews only for now, see ARCHITECTURE).
  final String appIconId;

  /// Whether the first-launch language prompt must be shown.
  bool get needsLanguageChoice => localeCode == null;

  AppSettings copyWith({
    String? localeCode,
    ThemeConfig? theme,
    ExternalCalendarSettings? externalCalendars,
    String? appIconId,
  }) {
    return AppSettings(
      localeCode: localeCode ?? this.localeCode,
      theme: theme ?? this.theme,
      externalCalendars: externalCalendars ?? this.externalCalendars,
      appIconId: appIconId ?? this.appIconId,
    );
  }
}

/// Read-only display of the device calendars (off until the user opts in).
class ExternalCalendarSettings {
  const ExternalCalendarSettings({this.enabled = false, this.hiddenCalendarIds = const {}});

  final bool enabled;

  /// Calendars the user chose not to show; new calendars are shown.
  final Set<String> hiddenCalendarIds;

  ExternalCalendarSettings copyWith({bool? enabled, Set<String>? hiddenCalendarIds}) =>
      ExternalCalendarSettings(
        enabled: enabled ?? this.enabled,
        hiddenCalendarIds: hiddenCalendarIds ?? this.hiddenCalendarIds,
      );

  Map<String, Object?> toJson() => {'enabled': enabled, 'hidden': hiddenCalendarIds.toList()};

  factory ExternalCalendarSettings.fromJson(Map<String, Object?> json) => ExternalCalendarSettings(
    enabled: json['enabled'] as bool? ?? false,
    hiddenCalendarIds: {...(json['hidden'] as List<Object?>? ?? const []).cast<String>()},
  );
}

/// How activity and goal cards are drawn (applies to all of them).
enum CardStyle {
  /// Full colored border and a soft neutral shadow.
  standard,

  /// No border: only the completion button is colored; soft neutral shadow.
  onlyButton,

  /// Full colored border and a shadow tinted with the card's color.
  coloredShadow,

  /// Colored border only on the lower half, fading out towards the top.
  halfBorder,

  /// No cards: activities are lines of a notebook page, with a colored square
  /// to tick in the left margin.
  paper,
}

/// The customizable colors of the theme.
enum ThemeColorSlot { text, page, surface, cards, navBar, accent, notification }

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
    this.cardStyle = CardStyle.standard,
    this.activityTextScale = 1.0,
  });

  /// Range of [activityTextScale] offered in Personalization.
  static const minActivityTextScale = 0.8;
  static const maxActivityTextScale = 1.4;

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

  /// How cards are drawn.
  final CardStyle cardStyle;

  /// Size of the activity texts (names, details, subtasks, widget) relative
  /// to the default; 1.0 is the default.
  final double activityTextScale;

  /// The override of [slot]; `null` means the preset default.
  int? colorOf(ThemeColorSlot slot) => switch (slot) {
    ThemeColorSlot.text => textColor,
    ThemeColorSlot.page => pageColor,
    ThemeColorSlot.surface => surfaceColor,
    ThemeColorSlot.cards => cardColor,
    ThemeColorSlot.navBar => navBarColor,
    ThemeColorSlot.accent => accentColor,
    ThemeColorSlot.notification => notificationColor,
  };

  /// A copy with [slot] set to [argb] (`null` restores the preset default).
  ThemeConfig withColor(ThemeColorSlot slot, int? argb) => ThemeConfig(
    presetId: presetId,
    textColor: slot == ThemeColorSlot.text ? argb : textColor,
    pageColor: slot == ThemeColorSlot.page ? argb : pageColor,
    surfaceColor: slot == ThemeColorSlot.surface ? argb : surfaceColor,
    cardColor: slot == ThemeColorSlot.cards ? argb : cardColor,
    navBarColor: slot == ThemeColorSlot.navBar ? argb : navBarColor,
    accentColor: slot == ThemeColorSlot.accent ? argb : accentColor,
    notificationColor: slot == ThemeColorSlot.notification ? argb : notificationColor,
    fontFamily: fontFamily,
    cardStyle: cardStyle,
    activityTextScale: activityTextScale,
  );

  /// A copy using [family] (`null` restores the preset font).
  ThemeConfig withFont(String? family) => _copy(fontFamily: family);

  /// A copy drawing cards with [style].
  ThemeConfig withCardStyle(CardStyle style) => _copy(cardStyle: style);

  /// A copy with activity texts at [scale] (clamped to the offered range).
  ThemeConfig withActivityTextScale(double scale) =>
      _copy(activityTextScale: scale.clamp(minActivityTextScale, maxActivityTextScale));

  /// Switches to [presetId], dropping the color overrides (they were chosen
  /// for the previous palette) but keeping font, card style and text size.
  ThemeConfig withPreset(String presetId) => ThemeConfig(
    presetId: presetId,
    fontFamily: fontFamily,
    cardStyle: cardStyle,
    activityTextScale: activityTextScale,
  );

  /// Marks an argument of [_copy] as "keep the current value".
  static const _keep = Object();

  /// A copy keeping every color; the other settings change when given
  /// ([fontFamily] may be set to `null`).
  ThemeConfig _copy({
    Object? fontFamily = _keep,
    CardStyle? cardStyle,
    double? activityTextScale,
  }) => ThemeConfig(
    presetId: presetId,
    textColor: textColor,
    pageColor: pageColor,
    surfaceColor: surfaceColor,
    cardColor: cardColor,
    navBarColor: navBarColor,
    accentColor: accentColor,
    notificationColor: notificationColor,
    fontFamily: identical(fontFamily, _keep) ? this.fontFamily : fontFamily as String?,
    cardStyle: cardStyle ?? this.cardStyle,
    activityTextScale: activityTextScale ?? this.activityTextScale,
  );

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
    'cardStyle': cardStyle.name,
    'activityTextScale': activityTextScale,
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
    cardStyle: CardStyle.values.asNameMap()[json['cardStyle']] ?? CardStyle.standard,
    activityTextScale: (json['activityTextScale'] as num?)?.toDouble() ?? 1.0,
  );
}
