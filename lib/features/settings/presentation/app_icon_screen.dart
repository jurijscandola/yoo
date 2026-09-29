import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/yoo_tokens.dart';
import '../../../l10n/l10n.dart';
import 'settings_providers.dart';

/// An app icon choice. The artwork is a placeholder (a "Y" on a colored
/// square) until the final icons exist; switching the launcher icon also
/// needs native setup (Android activity-alias, iOS alternate icons).
class AppIconOption {
  const AppIconOption(this.id, this.background, this.foreground, [this.gradientEnd]);

  final String id;
  final Color background;
  final Color foreground;

  /// Second gradient color, if any.
  final Color? gradientEnd;

  static const all = [
    AppIconOption('classic', Color(0xFF1E1D1B), Color(0xFFFAF8F4)),
    AppIconOption('light', Color(0xFFFAF8F4), Color(0xFF1E1D1B)),
    AppIconOption('dark', Color(0xFF111112), Color(0xFF7DA7E0)),
    AppIconOption('ocean', Color(0xFF0090FF), Colors.white, Color(0xFF12A594)),
    AppIconOption('forest', Color(0xFF4F7A4A), Colors.white, Color(0xFF1E2A1E)),
    AppIconOption('sunset', Color(0xFFF76B15), Colors.white, Color(0xFFD6409F)),
  ];

  static AppIconOption byId(String id) =>
      all.firstWhere((o) => o.id == id, orElse: () => all.first);

  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (id) {
      'light' => l10n.appIconLight,
      'dark' => l10n.appIconDark,
      'ocean' => l10n.appIconOcean,
      'forest' => l10n.appIconForest,
      'sunset' => l10n.appIconSunset,
      _ => l10n.appIconClassic,
    };
  }
}

/// Placeholder rendering of an icon, shaped like a launcher icon.
class AppIconPreview extends StatelessWidget {
  const AppIconPreview({super.key, required this.option, this.size = 72});

  final AppIconOption option;
  final double size;

  @override
  Widget build(BuildContext context) {
    final end = option.gradientEnd;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: end == null ? option.background : null,
        gradient: end == null
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [option.background, end],
              ),
        borderRadius: BorderRadius.circular(size * 0.26),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: size * 0.1)],
      ),
      child: Text(
        'Y',
        style: TextStyle(
          color: option.foreground,
          fontSize: size * 0.5,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

/// Grid of icon previews; the choice is stored in the settings.
class AppIconScreen extends ConsumerWidget {
  const AppIconScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final selected = ref.watch(currentSettingsProvider.select((s) => s.appIconId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appIcon)),
      // Keeps the end of the list above the system navigation bar
      // (edge-to-edge on Android 15+).
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(l10n.appIconHint, style: TextStyle(color: t.textMuted)),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
              children: [
                for (final option in AppIconOption.all)
                  Semantics(
                    button: true,
                    selected: option.id == selected,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(t.radius),
                      onTap: () => ref.read(settingsControllerProvider).setAppIcon(option.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: option.id == selected ? t.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(t.radius),
                          border: Border.all(
                            color: option.id == selected ? t.accent : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppIconPreview(option: option, size: 64),
                            const SizedBox(height: 8),
                            Text(option.label(context), style: TextStyle(color: t.text)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
