import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/yoo_tokens.dart';
import '../../../core/widgets/yoo_icon.dart';
import '../../../l10n/l10n.dart';
import 'settings_providers.dart';

/// Localized name of the app icon [id].
String appIconLabel(BuildContext context, String id) {
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

/// Grid of app icons. On Android the choice replaces the launcher icon (the
/// app closes to do it, after a confirmation); elsewhere only the logo shown
/// at startup follows it.
class AppIconScreen extends ConsumerWidget {
  const AppIconScreen({super.key});

  Future<void> _choose(BuildContext context, WidgetRef ref, String id, String selected) async {
    if (id == selected) return;
    final launcher = ref.read(launcherIconProvider);
    final settings = ref.read(settingsControllerProvider);
    if (!launcher.isSupported) {
      await settings.setAppIcon(id);
      return;
    }
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.appIconConfirmTitle(appIconLabel(context, id))),
        content: Text(l10n.appIconConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.appIconApply)),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    await settings.setAppIcon(id);
    await launcher.apply(id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final supported = ref.watch(launcherIconProvider).isSupported;
    // What the launcher shows wins over the stored choice (they can differ
    // after a reinstall); the stored choice is used where the device cannot
    // tell.
    final stored = ref.watch(currentSettingsProvider.select((s) => s.appIconId));
    final selected = ref.watch(launcherIconIdProvider).value ?? stored;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appIcon)),
      // Keeps the end of the list above the system navigation bar
      // (edge-to-edge on Android 15+).
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(
              supported ? l10n.appIconHint : l10n.appIconHintInApp,
              style: TextStyle(color: t.textMuted),
            ),
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
                      onTap: () => _choose(context, ref, option.id, selected),
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
                            YooIcon(option: option, size: 64, shadow: true),
                            const SizedBox(height: 8),
                            Text(appIconLabel(context, option.id), style: TextStyle(color: t.text)),
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
