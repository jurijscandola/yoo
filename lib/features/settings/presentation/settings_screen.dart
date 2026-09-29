import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/yoo_tokens.dart';
import '../../../l10n/l10n.dart';
import 'settings_providers.dart';

/// Settings: export, personalization and language.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final localeCode = ref.watch(appLocaleProvider).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          SettingsTile(
            icon: Icons.file_download_outlined,
            title: l10n.settingsExport,
            subtitle: l10n.settingsExportSubtitle,
            onTap: () => _comingSoon(context),
          ),
          SettingsTile(
            icon: Icons.palette_outlined,
            title: l10n.settingsPersonalization,
            subtitle: l10n.settingsPersonalizationSubtitle,
            onTap: () => _comingSoon(context),
          ),
          SettingsTile(
            icon: Icons.translate,
            title: l10n.settingsLanguage,
            subtitle: languageName(context, localeCode),
            onTap: () => _pickLanguage(context, ref, localeCode),
          ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.comingSoon)));
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref, String current) async {
    final code = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final c in supportedLanguageCodes)
              ListTile(
                title: Text(languageName(context, c)),
                trailing: c == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(c),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (code != null) await ref.read(settingsControllerProvider).setLocale(code);
  }
}

/// UI languages offered to the user.
const supportedLanguageCodes = ['en', 'it'];

/// Human-readable name of a language code, in that language.
String languageName(BuildContext context, String code) => switch (code) {
  'it' => context.l10n.languageItalian,
  _ => context.l10n.languageEnglish,
};

/// A rounded settings row drawn on the surface color.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radius),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(icon, color: t.text),
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle!, style: TextStyle(color: t.textMuted)),
          trailing: Icon(Icons.chevron_right, color: t.textMuted),
          onTap: onTap,
        ),
      ),
    );
  }
}
