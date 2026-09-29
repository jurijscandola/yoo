import 'package:flutter/material.dart';

import '../../../../core/theme/yoo_palettes.dart';
import '../../../../core/theme/yoo_tokens.dart';
import '../../../../core/time/date_labels.dart';
import '../../../../core/time/local_time.dart';

/// A titled block of the activity form, drawn on the surface color.
class FormSection extends StatelessWidget {
  const FormSection({super.key, required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // A Material (not a decorated box) so that ListTiles inside show their ink.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radius),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: t.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Seven round toggles, one per weekday (ISO 1 = Monday).
class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker({super.key, required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var d = 1; d <= 7; d++)
          _RoundToggle(
            label: context.shortWeekday(d).substring(0, 2),
            selected: d == selected,
            onTap: () => onChanged(d),
          ),
      ],
    );
  }
}

/// A 7-column grid of the days 1–31, single or multiple selection.
class MonthDayGrid extends StatelessWidget {
  const MonthDayGrid({super.key, required this.selected, required this.onToggle});

  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = (constraints.maxWidth - 6 * 6) / 7;
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var d = 1; d <= 31; d++)
              SizedBox.square(
                dimension: size,
                child: _RoundToggle(
                  label: '$d',
                  selected: selected.contains(d),
                  onTap: () => onToggle(d),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RoundToggle extends StatelessWidget {
  const _RoundToggle({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? t.accent : t.page),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? t.onAccent : t.text,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// The 16 border colors as selectable circles.
class BorderColorPicker extends StatelessWidget {
  const BorderColorPicker({super.key, required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < YooPalettes.borderColors.length; i++)
          GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: i == selected ? t.text : Colors.transparent, width: 2),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: YooPalettes.borderColors[i],
                  // Hairline so that colors close to the background (black on
                  // a dark theme) stay visible.
                  border: Border.all(color: t.text.withValues(alpha: 0.25)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// "−  value  +" counter.
class CountStepper extends StatelessWidget {
  const CountStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_rounded),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton.filledTonal(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

/// A labeled button opening the time picker.
class TimeButton extends StatelessWidget {
  const TimeButton({super.key, required this.label, required this.time, required this.onChanged});

  final String label;
  final LocalTime time;
  final ValueChanged<LocalTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      borderRadius: BorderRadius.circular(t.radius),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: time.hour, minute: time.minute),
        );
        if (picked != null) onChanged(LocalTime(picked.hour, picked.minute));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: t.page, borderRadius: BorderRadius.circular(t.radius)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: t.textMuted, fontSize: 11)),
            Text(context.timeLabel(time), style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
