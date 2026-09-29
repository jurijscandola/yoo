import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/key_value_store.dart';
import '../../core/theme/yoo_tokens.dart';
import '../../core/widgets/yoo_logo.dart';
import '../../features/reminders/presentation/reminder_providers.dart';
import '../../features/settings/presentation/settings_providers.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../l10n/l10n.dart';
import '../providers.dart';
import '../services.dart';

/// Wraps the app with the cold-start experience:
/// 1. the opening animation, played on every cold start;
/// 2. the language prompt, shown once on the very first launch;
/// 3. the reminder permission prompts (notifications, then exact alarms),
///    shown once when something is missing.
class StartupGate extends ConsumerStatefulWidget {
  const StartupGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<StartupGate> createState() => _StartupGateState();
}

/// Which permission prompt is on screen.
enum _PermissionStep { none, notifications, exactAlarms }

class _StartupGateState extends ConsumerState<StartupGate> {
  bool _splashDone = false;
  bool _permissionsChecked = false;
  _PermissionStep _permissionStep = _PermissionStep.none;

  /// Shows the first missing permission prompt, once per install.
  Future<void> _checkPermissions() async {
    if (_permissionsChecked) return;
    _permissionsChecked = true;
    final store = ref.read(keyValueStoreProvider);
    if (await store.read(StoreKeys.permissionsAsked) != null) return;
    final permissions = ref.read(reminderPermissionsProvider);
    final _PermissionStep step;
    if (!await permissions.notificationsAllowed()) {
      step = _PermissionStep.notifications;
    } else if (!await permissions.exactAlarmsAllowed()) {
      step = _PermissionStep.exactAlarms;
    } else {
      return;
    }
    if (mounted) setState(() => _permissionStep = step);
  }

  Future<void> _onPermissionContinue() async {
    final permissions = ref.read(reminderPermissionsProvider);
    switch (_permissionStep) {
      case _PermissionStep.notifications:
        final granted = await permissions.requestNotifications();
        if (granted && !await permissions.exactAlarmsAllowed()) {
          if (mounted) setState(() => _permissionStep = _PermissionStep.exactAlarms);
          return;
        }
      case _PermissionStep.exactAlarms:
        await permissions.requestExactAlarms();
      case _PermissionStep.none:
        break;
    }
    await _finishPermissions();
  }

  /// Remembers the prompt was shown and reschedules with what was granted
  /// (exact or inexact alarms).
  Future<void> _finishPermissions() async {
    if (mounted) setState(() => _permissionStep = _PermissionStep.none);
    final refreshReminders = ref.read(reminderRefreshProvider);
    ref.invalidate(reminderPermissionStatusProvider);
    await ref.read(keyValueStoreProvider).write(StoreKeys.permissionsAsked, 'true');
    await refreshReminders();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final needsLanguage = settings.value?.needsLanguageChoice ?? false;
    if (_splashDone && settings.hasValue && !needsLanguage && !_permissionsChecked) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkPermissions());
    }
    final l10n = context.l10n;
    return Stack(
      children: [
        widget.child,
        if (_splashDone) _AnimatedPresence(visible: needsLanguage, child: const _LanguagePrompt()),
        if (_splashDone)
          _AnimatedPresence(
            visible: _permissionStep != _PermissionStep.none,
            child: switch (_permissionStep) {
              _PermissionStep.exactAlarms => _PermissionPrompt(
                key: const ValueKey(_PermissionStep.exactAlarms),
                icon: Icons.alarm_on_outlined,
                title: l10n.permExactTitle,
                body: l10n.permExactBody,
                onContinue: _onPermissionContinue,
                onLater: _finishPermissions,
              ),
              _ => _PermissionPrompt(
                key: const ValueKey(_PermissionStep.notifications),
                icon: Icons.notifications_active_outlined,
                title: l10n.permTitle,
                body: l10n.permBody,
                onContinue: _onPermissionContinue,
                onLater: _finishPermissions,
              ),
            },
          ),
        if (!_splashDone)
          SplashOverlay(
            // Wait for the settings too, so the prompt never flickers.
            ready: settings.hasValue,
            onFinished: () => setState(() => _splashDone = true),
          ),
      ],
    );
  }
}

/// Opening animation: the logo pops in, the name slides up, then the whole
/// overlay fades out revealing the app.
class SplashOverlay extends StatefulWidget {
  const SplashOverlay({super.key, required this.ready, required this.onFinished});

  /// Whether the app is ready to be revealed once the intro has played.
  final bool ready;
  final VoidCallback onFinished;

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final AnimationController _outro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  @override
  void initState() {
    super.initState();
    _intro.forward().whenComplete(_maybeFinish);
  }

  @override
  void didUpdateWidget(covariant SplashOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ready && !oldWidget.ready) _maybeFinish();
  }

  void _maybeFinish() {
    if (!mounted || !_intro.isCompleted || !widget.ready || _outro.isAnimating) return;
    _outro.forward().whenComplete(() {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _outro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final logoScale = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0, 0.6, curve: Curves.elasticOut),
    );
    final nameIn = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(_outro),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 1,
          end: 1.06,
        ).animate(CurvedAnimation(parent: _outro, curve: Curves.easeIn)),
        child: ColoredBox(
          color: t.page,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(scale: logoScale, child: const YooLogo(size: 88)),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: nameIn,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(nameIn),
                    child: Text(
                      'Yoo',
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        color: t.text,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// First-launch language chooser, drawn as a card over a dimmed backdrop.
class _LanguagePrompt extends ConsumerWidget {
  const _LanguagePrompt();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(t.radius + 8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: YooLogo(size: 48)),
              const SizedBox(height: 16),
              Text(
                l10n.languagePromptTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.languagePromptSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: t.textMuted),
              ),
              const SizedBox(height: 16),
              for (final code in supportedLanguageCodes)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: t.text,
                      side: BorderSide(color: t.divider, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radius)),
                    ),
                    onPressed: () => ref.read(settingsControllerProvider).setLocale(code),
                    child: Text(languageName(context, code)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Explains why a permission is needed before the system asks for it.
class _PermissionPrompt extends StatelessWidget {
  const _PermissionPrompt({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.onContinue,
    required this.onLater,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onContinue;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(t.radius + 8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(icon, size: 44, color: t.accent),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(color: t.textMuted),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radius)),
                ),
                onPressed: onContinue,
                child: Text(l10n.permContinue),
              ),
              const SizedBox(height: 4),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: t.textMuted),
                onPressed: onLater,
                child: Text(l10n.permLater),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades and scales its child in and out, removing it when hidden.
class _AnimatedPresence extends StatelessWidget {
  const _AnimatedPresence({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: visible ? child : const SizedBox.shrink(),
    );
  }
}
