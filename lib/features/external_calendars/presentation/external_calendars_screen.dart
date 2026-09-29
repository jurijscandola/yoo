import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/yoo_tokens.dart';
import '../../../l10n/l10n.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/external_calendar_source.dart';
import 'external_calendar_providers.dart';

/// Settings page of the device calendars: opt-in (asking the permission) and
/// the choice of the calendars to show.
class ExternalCalendarsScreen extends ConsumerStatefulWidget {
  const ExternalCalendarsScreen({super.key});

  @override
  ConsumerState<ExternalCalendarsScreen> createState() => _ExternalCalendarsScreenState();
}

class _ExternalCalendarsScreenState extends ConsumerState<ExternalCalendarsScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // The permission can be changed in the system settings meanwhile.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(externalCalendarAccessProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _setEnabled(bool enabled) async {
    final controller = ref.read(settingsControllerProvider);
    final config = ref.read(currentSettingsProvider).externalCalendars;
    if (enabled) {
      final source = ref.read(externalCalendarSourceProvider);
      var access = await source.access();
      if (access == ExternalCalendarAccess.askable) access = await source.requestAccess();
      ref.invalidate(externalCalendarAccessProvider);
      if (access != ExternalCalendarAccess.granted) return;
    }
    await controller.setExternalCalendars(config.copyWith(enabled: enabled));
  }

  Future<void> _setShown(String calendarId, bool shown) {
    final config = ref.read(currentSettingsProvider).externalCalendars;
    final hidden = {...config.hiddenCalendarIds};
    shown ? hidden.remove(calendarId) : hidden.add(calendarId);
    return ref
        .read(settingsControllerProvider)
        .setExternalCalendars(config.copyWith(hiddenCalendarIds: hidden));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final config = ref.watch(currentSettingsProvider.select((s) => s.externalCalendars));
    final access = ref.watch(externalCalendarAccessProvider).value;
    final calendars = ref.watch(externalCalendarsProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsCalendars)),
      // Keeps the end of the list above the system navigation bar
      // (edge-to-edge on Android 15+).
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            Material(
              color: t.surface,
              borderRadius: BorderRadius.circular(t.radius),
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile(
                title: Text(l10n.calendarsEnable),
                subtitle: Text(l10n.externalReadOnly, style: TextStyle(color: t.textMuted)),
                value: config.enabled && access == ExternalCalendarAccess.granted,
                onChanged: _setEnabled,
              ),
            ),
            if (access == ExternalCalendarAccess.denied) ...[
              const SizedBox(height: 12),
              Material(
                color: t.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(t.radius),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(l10n.calendarsDenied, style: TextStyle(color: t.text)),
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.read(externalCalendarSourceProvider).openSystemSettings(),
                        child: Text(l10n.openSettings),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (config.enabled &&
                access == ExternalCalendarAccess.granted &&
                calendars != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 20, 4, 6),
                child: Text(
                  l10n.calendarsPick,
                  style: TextStyle(color: t.textMuted, fontWeight: FontWeight.w600),
                ),
              ),
              if (calendars.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.calendarsNone, style: TextStyle(color: t.textMuted)),
                )
              else
                Material(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(t.radius),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (final c in calendars)
                        CheckboxListTile(
                          value: !config.hiddenCalendarIds.contains(c.id),
                          onChanged: (shown) => _setShown(c.id, shown ?? false),
                          secondary: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: c.colorArgb == null ? t.accent : Color(c.colorArgb!),
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(c.name),
                          subtitle: c.account == null || c.account == c.name
                              ? null
                              : Text(c.account!, style: TextStyle(color: t.textMuted)),
                        ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
