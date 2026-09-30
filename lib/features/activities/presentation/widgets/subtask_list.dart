import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/services.dart';
import '../../../../core/theme/yoo_tokens.dart';
import '../../../../core/time/local_date.dart';
import '../../../../core/widgets/raised_surface.dart';
import '../../../../l10n/l10n.dart';
import '../../../settings/domain/app_settings.dart';
import '../../domain/entities/subtask.dart';
import '../activity_providers.dart';

/// The arrow next to the "⋯" of a card: expands the subtasks. Shows how many
/// are checked on [date] ("1/3") once the activity has some.
class SubtaskToggle extends ConsumerWidget {
  const SubtaskToggle({
    super.key,
    required this.activityId,
    required this.date,
    required this.expanded,
    required this.onPressed,
  });

  final String activityId;
  final LocalDate date;
  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final total = ref.watch(subtasksProvider(activityId)).value?.length ?? 0;
    final checked = ref.watch(checkedSubtasksProvider((activityId, date))).value?.length ?? 0;
    return Tooltip(
      message: context.l10n.subtasksToggle,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (total > 0)
                Text(
                  '$checked/$total',
                  style: TextStyle(
                    color: checked == total ? t.success : t.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.keyboard_arrow_down_rounded, color: t.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The expanded subtasks of an activity on [date], with "+ Add subtask".
///
/// Checking is possible when [canCheck] (today); adding, renaming (long press)
/// and deleting work on any day, since subtasks belong to the activity.
///
/// In the paper card style boxes and the "+" sit in the notebook margin and
/// the texts start after the margin line, like the activity itself.
class SubtaskList extends ConsumerStatefulWidget {
  const SubtaskList({
    super.key,
    required this.activityId,
    required this.date,
    required this.canCheck,
    required this.color,
  });

  final String activityId;
  final LocalDate date;
  final bool canCheck;
  final Color color;

  @override
  ConsumerState<SubtaskList> createState() => _SubtaskListState();
}

class _SubtaskListState extends ConsumerState<SubtaskList> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  bool _adding = false;

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Adds the typed subtask and keeps the field open for the next one; an
  /// empty submit closes it.
  Future<void> _submit() async {
    final text = _input.text;
    if (text.trim().isEmpty) {
      setState(() => _adding = false);
      return;
    }
    _input.clear();
    _focus.requestFocus();
    await ref.read(subtaskServiceProvider).add(widget.activityId, text);
  }

  Future<void> _edit(Subtask subtask) async {
    final result = await showDialog<_EditResult>(
      context: context,
      builder: (context) => _SubtaskDialog(subtask: subtask),
    );
    if (result == null) return;
    final service = ref.read(subtaskServiceProvider);
    switch (result) {
      case _Rename(:final title):
        await service.rename(subtask, title);
      case _Delete():
        await service.delete(subtask);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final subtasks = ref.watch(subtasksProvider(widget.activityId)).value ?? const <Subtask>[];
    final checked =
        ref.watch(checkedSubtasksProvider((widget.activityId, widget.date))).value ??
        const <String>{};
    final paper = t.cardStyle == CardStyle.paper;
    // Where texts start in the paper style: after the margin line.
    const paperTextStart = RaisedSurface.paperMarginWidth + 12;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: t.divider)),
      ),
      padding: paper
          ? const EdgeInsets.fromLTRB(0, 2, 12, 4)
          : const EdgeInsets.fromLTRB(4, 4, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final s in subtasks)
            _SubtaskRow(
              subtask: s,
              checked: checked.contains(s.id),
              color: widget.color,
              paper: paper,
              onChanged: widget.canCheck
                  ? (v) => ref.read(subtaskServiceProvider).setChecked(s, widget.date, checked: v)
                  : null,
              onEdit: () => _edit(s),
            ),
          if (_adding)
            Padding(
              padding: EdgeInsets.only(left: paper ? paperTextStart : 12, top: 4, bottom: 4),
              child: TextField(
                controller: _input,
                focusNode: _focus,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: l10n.subtaskHint,
                  fillColor: t.page,
                  suffixIcon: IconButton(
                    tooltip: l10n.save,
                    icon: const Icon(Icons.check_rounded),
                    onPressed: _submit,
                  ),
                ),
                // Keeps the keyboard open to type several subtasks in a row.
                onEditingComplete: () {},
                onSubmitted: (_) => _submit(),
              ),
            )
          else if (paper)
            _PaperAddButton(label: l10n.subtaskAdd, onPressed: () => setState(() => _adding = true))
          else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _adding = true),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(l10n.subtaskAdd),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubtaskRow extends StatelessWidget {
  const _SubtaskRow({
    required this.subtask,
    required this.checked,
    required this.color,
    required this.paper,
    required this.onChanged,
    required this.onEdit,
  });

  final Subtask subtask;
  final bool checked;
  final Color color;

  /// Box in the notebook margin, text after the margin line.
  final bool paper;

  /// `null` when the day cannot be checked (read-only box).
  final ValueChanged<bool>? onChanged;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final onChanged = this.onChanged;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onChanged == null ? onEdit : () => onChanged(!checked),
      onLongPress: onEdit,
      child: Row(
        children: [
          SizedBox(
            width: paper ? RaisedSurface.paperMarginWidth : null,
            child: Center(
              child: Checkbox(
                value: checked,
                activeColor: color,
                onChanged: onChanged == null ? null : (v) => onChanged(v ?? false),
              ),
            ),
          ),
          if (paper) const SizedBox(width: 12),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: checked ? t.textMuted : t.text,
                decoration: checked ? TextDecoration.lineThrough : null,
                decorationColor: t.textMuted,
                fontSize: 15 * t.activityTextScale,
              ),
              child: Text(subtask.title),
            ),
          ),
        ],
      ),
    );
  }
}

/// "+ Add subtask" of the paper style: the "+" in the margin, the label
/// aligned with the texts.
class _PaperAddButton extends StatelessWidget {
  const _PaperAddButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color =
        Theme.of(context).textButtonTheme.style?.foregroundColor?.resolve(const {}) ??
        Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: [
            SizedBox(
              width: RaisedSurface.paperMarginWidth,
              child: Icon(Icons.add_rounded, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

sealed class _EditResult {}

class _Rename extends _EditResult {
  _Rename(this.title);
  final String title;
}

class _Delete extends _EditResult {}

/// Rename or delete a subtask.
class _SubtaskDialog extends StatefulWidget {
  const _SubtaskDialog({required this.subtask});

  final Subtask subtask;

  @override
  State<_SubtaskDialog> createState() => _SubtaskDialogState();
}

class _SubtaskDialogState extends State<_SubtaskDialog> {
  late final _controller = TextEditingController(text: widget.subtask.title);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.subtaskEdit),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (v) => Navigator.pop(context, _Rename(v)),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: context.tokens.danger),
          onPressed: () => Navigator.pop(context, _Delete()),
          child: Text(l10n.delete),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        TextButton(
          onPressed: () => Navigator.pop(context, _Rename(_controller.text)),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
