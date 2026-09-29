import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/services.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../l10n/l10n.dart';
import '../domain/monthly_goal.dart';

/// Dialogs to create, rename and delete monthly goals.
abstract final class GoalEditor {
  /// Creates a goal for [year]/[month].
  static Future<void> create(BuildContext context, WidgetRef ref, int year, int month) async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => _GoalDialog(title: context.l10n.goalAdd),
    );
    if (title == null) return;
    await ref.read(goalServiceProvider).create(year: year, month: month, title: title);
  }

  /// Renames or deletes [goal].
  static Future<void> edit(BuildContext context, WidgetRef ref, MonthlyGoal goal) async {
    final result = await showDialog<_EditResult>(
      context: context,
      builder: (context) => _GoalDialog(title: context.l10n.goalEdit, initial: goal.title),
    );
    if (result == null || !context.mounted) return;
    final service = ref.read(goalServiceProvider);
    if (result is _Rename) {
      if (result.title != goal.title) await service.rename(goal, result.title);
      return;
    }
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.goalDeleteTitle(goal.title)),
        content: Text(l10n.goalDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.tokens.danger),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await service.delete(goal);
  }
}

sealed class _EditResult {}

class _Rename extends _EditResult {
  _Rename(this.title);
  final String title;
}

class _Delete extends _EditResult {}

/// Title field with Save/Cancel; in edit mode also a Delete action. Pops a
/// `String` in create mode and an [_EditResult] in edit mode.
class _GoalDialog extends StatefulWidget {
  const _GoalDialog({required this.title, this.initial});

  final String title;

  /// Current title when editing; `null` when creating.
  final String? initial;

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  late final _controller = TextEditingController(text: widget.initial);
  bool _showError = false;

  bool get _editing => widget.initial != null;

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    Navigator.pop(context, _editing ? _Rename(text) : text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: l10n.goalTitleLabel,
          hintText: l10n.goalTitleHint,
          errorText: _showError ? l10n.errorEmptyGoal : null,
        ),
        onChanged: (_) {
          if (_showError) setState(() => _showError = false);
        },
        onSubmitted: (_) => _save(),
      ),
      actions: [
        if (_editing)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: t.danger),
            onPressed: () => Navigator.pop(context, _Delete()),
            child: Text(l10n.delete),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        TextButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
