import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/services.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../l10n/l10n.dart';
import '../domain/monthly_goal.dart';

/// Dialogs to create, rename and delete monthly goals.
abstract final class GoalEditor {
  /// Creates a goal for [year]/[month].
  static Future<void> create(BuildContext context, WidgetRef ref, int year, int month) async {
    final result = await showDialog<_Save>(
      context: context,
      builder: (context) => _GoalDialog(title: context.l10n.goalAdd),
    );
    if (result == null) return;
    await ref
        .read(goalServiceProvider)
        .create(year: year, month: month, title: result.title, target: result.target);
  }

  /// Renames, changes the target of, or deletes [goal].
  static Future<void> edit(BuildContext context, WidgetRef ref, MonthlyGoal goal) async {
    final result = await showDialog<_EditResult>(
      context: context,
      builder: (context) => _GoalDialog(title: context.l10n.goalEdit, initial: goal),
    );
    if (result == null || !context.mounted) return;
    final service = ref.read(goalServiceProvider);
    if (result is _Save) {
      if (result.title != goal.title || result.target != goal.target) {
        await service.update(goal, title: result.title, target: result.target);
      }
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

class _Save extends _EditResult {
  _Save(this.title, this.target);
  final String title;
  final int target;
}

class _Delete extends _EditResult {}

/// Title and target fields with Save/Cancel; in edit mode also a Delete
/// action. Pops an [_EditResult].
class _GoalDialog extends StatefulWidget {
  const _GoalDialog({required this.title, this.initial});

  final String title;

  /// The goal being edited; `null` when creating.
  final MonthlyGoal? initial;

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  late final _controller = TextEditingController(text: widget.initial?.title);
  late final _target = TextEditingController(text: '${widget.initial?.target ?? 1}');
  bool _showError = false;
  bool _showTargetError = false;

  bool get _editing => widget.initial != null;

  void _save() {
    final text = _controller.text.trim();
    final target = int.tryParse(_target.text.trim());
    final validTarget = target != null && target >= 1;
    if (text.isEmpty || !validTarget) {
      setState(() {
        _showError = text.isEmpty;
        _showTargetError = !validTarget;
      });
      return;
    }
    Navigator.pop(context, _Save(text, target));
  }

  @override
  void dispose() {
    _controller.dispose();
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    return AlertDialog(
      // Two fields: scroll instead of overflowing with large text.
      scrollable: true,
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
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
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _target,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l10n.goalTargetLabel,
              helperText: l10n.goalTargetHelp,
              helperMaxLines: 3,
              errorText: _showTargetError ? l10n.errorGoalTarget : null,
            ),
            onChanged: (_) {
              if (_showTargetError) setState(() => _showTargetError = false);
            },
            onSubmitted: (_) => _save(),
          ),
        ],
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
