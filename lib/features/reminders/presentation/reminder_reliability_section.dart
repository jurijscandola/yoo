import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/yoo_tokens.dart';
import '../../../l10n/l10n.dart';
import 'reminder_providers.dart';

/// Settings section showing what may stop reminders (missing permissions,
/// battery optimization) with a shortcut to fix each one.
class ReminderReliabilitySection extends ConsumerStatefulWidget {
  const ReminderReliabilitySection({super.key});

  @override
  ConsumerState<ReminderReliabilitySection> createState() => _ReminderReliabilitySectionState();
}

class _ReminderReliabilitySectionState extends ConsumerState<ReminderReliabilitySection> {
  late final AppLifecycleListener _lifecycle;

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    // Permissions are changed in system screens: re-read them on return.
    // (The day watcher refreshes the reminders on resume.)
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(reminderPermissionStatusProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _fixNotifications() async {
    final permissions = ref.read(reminderPermissionsProvider);
    // Once denied, the system dialog no longer appears: open the settings.
    if (!await permissions.requestNotifications()) await permissions.openSystemSettings();
    ref.invalidate(reminderPermissionStatusProvider);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final status = ref.watch(reminderPermissionStatusProvider).value;
    final permissions = ref.read(reminderPermissionsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 6),
          child: Text(
            l10n.settingsReliability,
            style: TextStyle(color: t.textMuted, fontWeight: FontWeight.w600),
          ),
        ),
        _StatusTile(
          icon: Icons.notifications_outlined,
          title: l10n.reliabilityNotifications,
          allowed: status?.notifications,
          onFix: _fixNotifications,
        ),
        if (_isAndroid)
          _StatusTile(
            icon: Icons.alarm_outlined,
            title: l10n.reliabilityExact,
            allowed: status?.exactAlarms,
            onFix: permissions.requestExactAlarms,
          ),
        if (_isAndroid)
          _Tile(
            icon: Icons.battery_saver_outlined,
            title: l10n.reliabilityBattery,
            subtitle: l10n.reliabilityBatteryHint,
            action: TextButton(
              onPressed: permissions.openSystemSettings,
              child: Text(l10n.openSettings),
            ),
          ),
      ],
    );
  }
}

/// A permission row: "Allowed", or "Not allowed" with a tap to fix it.
class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.title,
    required this.allowed,
    required this.onFix,
  });

  final IconData icon;
  final String title;

  /// `null` while loading.
  final bool? allowed;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final ok = allowed ?? true;
    return _Tile(
      icon: icon,
      title: title,
      subtitle: allowed == null ? null : (ok ? l10n.statusAllowed : l10n.statusNotAllowed),
      subtitleColor: ok ? null : t.danger,
      trailing: allowed == null
          ? null
          : Icon(ok ? Icons.check_circle : Icons.error_outline, color: ok ? t.success : t.danger),
      onTap: ok ? null : onFix,
    );
  }
}

/// A rounded row drawn on the surface color, like the other settings rows.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    this.trailing,
    this.action,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? trailing;

  /// Button shown under the subtitle (a trailing one would not fit large text).
  final Widget? action;
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
          subtitle: subtitle == null && action == null
              ? null
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subtitle != null)
                      Text(subtitle!, style: TextStyle(color: subtitleColor ?? t.textMuted)),
                    ?action,
                  ],
                ),
          trailing: trailing,
          onTap: onTap,
        ),
      ),
    );
  }
}
