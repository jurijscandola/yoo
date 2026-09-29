import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/yoo_fonts.dart';
import '../../../core/theme/yoo_palettes.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../l10n/l10n.dart';
import '../domain/app_settings.dart';
import 'app_icon_screen.dart';
import 'settings_providers.dart';

/// Personalization: theme presets, the color of every element, the font and
/// the app icon. Changes apply (and animate) immediately; the preview at the
/// top shows the main elements together.
class PersonalizationScreen extends ConsumerWidget {
  const PersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final settings = ref.watch(currentSettingsProvider);
    final theme = settings.theme;
    final controller = ref.read(settingsControllerProvider);

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        text,
        style: TextStyle(color: t.textMuted, fontWeight: FontWeight.w600),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsPersonalization)),
      // Keeps the end of the list above the system navigation bar
      // (edge-to-edge on Android 15+).
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const ThemePreview(),
            header(l10n.themePresets),
            MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.3,
              child: SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: YooPalettes.presets.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final preset = YooPalettes.presets[i];
                    return _PresetChip(
                      preset: preset,
                      label: presetName(context, preset.id),
                      selected: preset.id == theme.presetId,
                      onTap: () => controller.updateTheme((c) => c.withPreset(preset.id)),
                    );
                  },
                ),
              ),
            ),
            header(l10n.themeColors),
            _Group(
              children: [
                for (final slot in ThemeColorSlot.values)
                  _ColorRow(
                    slot: slot,
                    current: slotColor(t, slot),
                    overridden: theme.colorOf(slot) != null,
                    onPick: (argb) => controller.updateTheme((c) => c.withColor(slot, argb)),
                  ),
              ],
            ),
            header(l10n.themeFont),
            _Group(
              children: [
                for (final family in YooFonts.options)
                  ListTile(
                    title: Text(
                      family ?? l10n.fontSystem,
                      style: TextStyle(fontFamily: family, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      l10n.fontSample,
                      style: TextStyle(fontFamily: family, color: t.textMuted),
                    ),
                    trailing: theme.fontFamily == family
                        ? Icon(Icons.check_rounded, color: t.accent)
                        : null,
                    onTap: () => controller.updateTheme((c) => c.withFont(family)),
                  ),
              ],
            ),
            header(l10n.appIcon),
            _Group(
              children: [
                ListTile(
                  leading: AppIconPreview(option: AppIconOption.byId(settings.appIconId), size: 40),
                  title: Text(AppIconOption.byId(settings.appIconId).label(context)),
                  trailing: Icon(Icons.chevron_right, color: t.textMuted),
                  onTap: () => context.push(Routes.appIcon),
                ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: t.text,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: t.divider, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radius)),
              ),
              icon: const Icon(Icons.restart_alt),
              label: Text(l10n.themeReset),
              onPressed: () => controller.setTheme(const ThemeConfig()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Localized name of a preset.
String presetName(BuildContext context, String id) {
  final l10n = context.l10n;
  return switch (id) {
    'mist' => l10n.presetMist,
    'sage' => l10n.presetSage,
    'night' => l10n.presetNight,
    'ink' => l10n.presetInk,
    _ => l10n.presetPaper,
  };
}

/// The color [slot] currently resolves to.
Color slotColor(YooTokens t, ThemeColorSlot slot) => switch (slot) {
  ThemeColorSlot.text => t.text,
  ThemeColorSlot.page => t.page,
  ThemeColorSlot.surface => t.surface,
  ThemeColorSlot.cards => t.card,
  ThemeColorSlot.navBar => t.navBar,
  ThemeColorSlot.accent => t.accent,
  ThemeColorSlot.notification => t.notification,
};

String _slotLabel(BuildContext context, ThemeColorSlot slot) {
  final l10n = context.l10n;
  return switch (slot) {
    ThemeColorSlot.text => l10n.colorText,
    ThemeColorSlot.page => l10n.colorPage,
    ThemeColorSlot.surface => l10n.colorSurface,
    ThemeColorSlot.cards => l10n.colorCards,
    ThemeColorSlot.navBar => l10n.colorBar,
    ThemeColorSlot.accent => l10n.colorAccent,
    ThemeColorSlot.notification => l10n.colorNotification,
  };
}

/// Backgrounds get light/dark tones; text and accents get vivid ones.
List<Color> _swatchesFor(ThemeColorSlot slot) => switch (slot) {
  ThemeColorSlot.page ||
  ThemeColorSlot.surface ||
  ThemeColorSlot.cards ||
  ThemeColorSlot.navBar => YooPalettes.backgroundSwatches,
  _ => YooPalettes.foregroundSwatches,
};

/// Rows on a rounded surface.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(t.radius),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.preset,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final YooPreset preset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 84,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: preset.page,
            borderRadius: BorderRadius.circular(t.radius),
            border: Border.all(color: selected ? t.accent : t.divider, width: selected ? 2.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 22,
                decoration: BoxDecoration(
                  color: preset.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 5),
                child: CircleAvatar(radius: 5, backgroundColor: preset.accent),
              ),
              const Spacer(),
              ExcludeSemantics(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: preset.text, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A color setting: tapping opens the swatches.
class _ColorRow extends StatelessWidget {
  const _ColorRow({
    required this.slot,
    required this.current,
    required this.overridden,
    required this.onPick,
  });

  final ThemeColorSlot slot;
  final Color current;
  final bool overridden;

  /// Called with the chosen ARGB, or `null` for the preset default.
  final ValueChanged<int?> onPick;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    return ListTile(
      title: Text(_slotLabel(context, slot)),
      subtitle: slot == ThemeColorSlot.notification
          ? Text(l10n.colorNotificationHint, style: TextStyle(color: t.textMuted))
          : !overridden
          ? Text(l10n.colorDefault, style: TextStyle(color: t.textMuted))
          : null,
      trailing: _Swatch(color: current, size: 28),
      onTap: () => _pick(context),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final t = context.tokens;
    final l10n = context.l10n;
    // Wrapped so that "Default" (null) differs from a dismissed sheet.
    final picked = await showModalBottomSheet<({int? argb})>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_slotLabel(context, slot), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final c in _swatchesFor(slot))
                    GestureDetector(
                      onTap: () => Navigator.pop(context, (argb: c.toARGB32())),
                      child: _Swatch(
                        color: c,
                        size: 40,
                        selected: overridden && c.toARGB32() == current.toARGB32(),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: t.text),
                onPressed: () => Navigator.pop(context, (argb: null)),
                child: Text(l10n.colorDefault),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onPick(picked.argb);
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.size, this.selected = false});

  final Color color;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? t.accent : t.text.withValues(alpha: 0.15),
          width: selected ? 3 : 1,
        ),
      ),
      child: selected
          ? Icon(
              Icons.check,
              size: size * 0.5,
              color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            )
          : null,
    );
  }
}

/// A small mock of Home drawn with the current tokens: header, two cards,
/// the "+" button, the navigation bar and a notification.
class ThemePreview extends StatelessWidget {
  const ThemePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    Widget card(String name, Color border) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(t.radius * 0.6),
        border: Border.all(color: border, width: t.cardBorderWidth),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: border, width: 2),
            ),
          ),
        ],
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(t.radius + 4),
      child: Container(
        decoration: BoxDecoration(
          color: t.page,
          border: Border.all(color: t.divider),
          borderRadius: BorderRadius.circular(t.radius + 4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  Icon(Icons.notifications, size: 16, color: t.notification),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Yoo · ${l10n.previewActivityOne}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: t.textMuted, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(t.radius * 0.7),
              ),
              child: Text(
                l10n.today,
                style: TextStyle(color: t.text, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  card(l10n.previewActivityOne, YooPalettes.borderColor(8)),
                  card(l10n.previewActivityTwo, YooPalettes.borderColor(1)),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 12, 8),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: t.accent,
                  borderRadius: BorderRadius.circular(t.radius * 0.6),
                ),
                child: Icon(Icons.add_rounded, color: t.onAccent, size: 22),
              ),
            ),
            Container(
              color: t.navBar,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.calendar_month_outlined, color: t.textMuted, size: 20),
                  Icon(Icons.home_rounded, color: t.text, size: 20),
                  Icon(Icons.flag_outlined, color: t.textMuted, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
