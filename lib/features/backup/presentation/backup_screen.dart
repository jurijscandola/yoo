import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/yoo_tokens.dart';
import '../../../core/time/date_labels.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/l10n.dart';
import '../../export/presentation/export_providers.dart';
import '../domain/backup_file.dart';
import 'backup_providers.dart';

/// Full backup: export everything to a file, or import a file to fill the
/// app again. Importing never deletes anything.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function(ScaffoldMessengerState messenger) action) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action(messenger);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export() => _run((messenger) async {
    final failed = context.l10n.exportFailed;
    final service = ref.read(backupServiceProvider);
    try {
      final name = service.fileName();
      await ref
          .read(exportDestinationProvider)
          .deliver(
            fileName: name,
            content: await service.export(),
            subject: name,
            mimeType: 'application/json',
          );
    } catch (error) {
      debugPrint('Backup export failed: $error');
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  });

  Future<void> _import() => _run((messenger) async {
    final l10n = context.l10n;
    final service = ref.read(backupServiceProvider);
    final String? text;
    try {
      text = await ref.read(backupFileSourceProvider).pickText();
    } catch (error) {
      debugPrint('Backup pick failed: $error');
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupImportFailed)));
      return;
    }
    if (text == null || !mounted) return;

    final BackupFile backup;
    try {
      backup = service.read(text);
    } on BackupFormatException catch (e) {
      final message = e.problem == BackupProblem.tooNew ? l10n.backupTooNew : l10n.backupInvalid;
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    if (!await _confirm(backup) || !mounted) return;

    try {
      final result = await service.restore(backup);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.backupImported(result.added, result.updated))),
      );
    } catch (error) {
      debugPrint('Backup import failed: $error');
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupImportFailed)));
    }
  });

  Future<bool> _confirm(BackupFile backup) async {
    final l10n = context.l10n;
    final made = backup.exportedAt;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.backupCreatedOn(context.fullDate(LocalDate.fromDateTime(made)))),
            const SizedBox(height: 8),
            Text(l10n.backupCountActivities(backup.activityCount)),
            Text(l10n.backupCountDays(backup.dayCount)),
            Text(l10n.backupCountGoals(backup.goalCount)),
            const SizedBox(height: 12),
            Text(l10n.backupImportHint, style: TextStyle(color: context.tokens.textMuted)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.backupImportConfirm),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final canImport = ref.watch(backupFileSourceProvider).isSupported;
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radius));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsBackup)),
      // Keeps the end of the list above the system navigation bar
      // (edge-to-edge on Android 15+).
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(l10n.backupDescription, style: TextStyle(color: t.textMuted)),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: buttonShape,
              ),
              icon: const Icon(Icons.ios_share),
              label: Text(l10n.backupExport),
              onPressed: _busy ? null : _export,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: t.text,
                shape: buttonShape,
              ),
              icon: const Icon(Icons.file_open_outlined),
              label: Text(l10n.backupImport),
              onPressed: _busy || !canImport ? null : _import,
            ),
            const SizedBox(height: 8),
            Text(
              canImport ? l10n.backupImportHint : l10n.backupImportUnsupported,
              style: TextStyle(color: t.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
