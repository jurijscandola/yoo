import 'package:flutter/material.dart';

/// A complete base palette the user can start from before customizing.
@immutable
class YooPreset {
  const YooPreset({
    required this.id,
    required this.brightness,
    required this.page,
    required this.surface,
    required this.text,
    required this.accent,
    required this.success,
    required this.danger,
    this.fontFamily,
  });

  final String id;
  final Brightness brightness;
  final Color page;
  final Color surface;
  final Color text;
  final Color accent;
  final Color success;
  final Color danger;
  final String? fontFamily;
}

/// Predefined palettes: presets, the 16 activity border colors and the
/// swatches offered for each customizable element.
abstract final class YooPalettes {
  /// Base presets. The first one is the default.
  static const presets = <YooPreset>[
    YooPreset(
      id: 'paper',
      brightness: Brightness.light,
      page: Color(0xFFECE9E2),
      surface: Color(0xFFFAF8F4),
      text: Color(0xFF1E1D1B),
      accent: Color(0xFF1E1D1B),
      success: Color(0xFF3A9D5D),
      danger: Color(0xFFD2483F),
    ),
    YooPreset(
      id: 'mist',
      brightness: Brightness.light,
      page: Color(0xFFE3E8EE),
      surface: Color(0xFFF7F9FB),
      text: Color(0xFF17212B),
      accent: Color(0xFF3D6FA8),
      success: Color(0xFF2F9A6A),
      danger: Color(0xFFCC4B4B),
    ),
    YooPreset(
      id: 'sage',
      brightness: Brightness.light,
      page: Color(0xFFE2E7DF),
      surface: Color(0xFFF6F8F3),
      text: Color(0xFF1C241B),
      accent: Color(0xFF4F7A4A),
      success: Color(0xFF3C8F52),
      danger: Color(0xFFC4503F),
    ),
    YooPreset(
      id: 'night',
      brightness: Brightness.dark,
      page: Color(0xFF111112),
      surface: Color(0xFF1F1F22),
      text: Color(0xFFECEBE8),
      accent: Color(0xFFECEBE8),
      success: Color(0xFF55C07A),
      danger: Color(0xFFEF6A5F),
    ),
    YooPreset(
      id: 'ink',
      brightness: Brightness.dark,
      page: Color(0xFF0E1420),
      surface: Color(0xFF1A2232),
      text: Color(0xFFE6EAF2),
      accent: Color(0xFF7DA7E0),
      success: Color(0xFF5CC08E),
      danger: Color(0xFFEE7070),
    ),
  ];

  /// Returns the preset with [id], or the default one if unknown.
  static YooPreset presetById(String id) =>
      presets.firstWhere((p) => p.id == id, orElse: () => presets.first);

  /// The 16 colors available for activity card borders (index-stable:
  /// activities store the index, so never reorder, only replace values).
  static const borderColors = <Color>[
    Color(0xFFE5484D), // red
    Color(0xFFF76B15), // orange
    Color(0xFFFFB224), // amber
    Color(0xFFE2C400), // yellow
    Color(0xFF99D52A), // lime
    Color(0xFF46A758), // green
    Color(0xFF12A594), // teal
    Color(0xFF00A2C7), // cyan
    Color(0xFF0090FF), // blue
    Color(0xFF3E63DD), // indigo
    Color(0xFF6E56CF), // violet
    Color(0xFFAB4ABA), // purple
    Color(0xFFD6409F), // pink
    Color(0xFFA18072), // brown
    Color(0xFF8B8D98), // gray
    Color(0xFF1E1D1B), // black
  ];

  /// Returns the border color for [index], clamped to the palette.
  static Color borderColor(int index) => borderColors[index.clamp(0, borderColors.length - 1)];

  /// Swatches offered for backgrounds (page, surfaces, navigation bar, cards).
  static const backgroundSwatches = <Color>[
    Color(0xFFFFFFFF),
    Color(0xFFFAF8F4),
    Color(0xFFECE9E2),
    Color(0xFFF7F9FB),
    Color(0xFFE3E8EE),
    Color(0xFFF6F8F3),
    Color(0xFFE2E7DF),
    Color(0xFFFBEFEF),
    Color(0xFFF3EDFA),
    Color(0xFFFFF6E0),
    Color(0xFF1F1F22),
    Color(0xFF111112),
    Color(0xFF1A2232),
    Color(0xFF0E1420),
    Color(0xFF1E2A1E),
    Color(0xFF2A1E24),
  ];

  /// Swatches offered for text and accent colors.
  static const foregroundSwatches = <Color>[
    Color(0xFF1E1D1B),
    Color(0xFF17212B),
    Color(0xFF3D3A35),
    Color(0xFF5B5750),
    Color(0xFFECEBE8),
    Color(0xFFFFFFFF),
    Color(0xFF3D6FA8),
    Color(0xFF4F7A4A),
    Color(0xFF7DA7E0),
    Color(0xFF6E56CF),
    Color(0xFFD6409F),
    Color(0xFFE5484D),
    Color(0xFFF76B15),
    Color(0xFF12A594),
    Color(0xFFA18072),
    Color(0xFF8B8D98),
  ];
}
