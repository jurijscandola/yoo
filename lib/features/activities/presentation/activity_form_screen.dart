import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/services.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../core/time/date_labels.dart';
import '../../../core/time/local_date.dart';
import '../../../core/time/local_time.dart';
import '../../../l10n/l10n.dart';
import '../../goals/presentation/goal_providers.dart';
import '../domain/entities/activity.dart';
import '../domain/entities/activity_draft.dart';
import '../domain/entities/recurrence.dart';
import 'activity_providers.dart';
import 'widgets/form_pickers.dart';

/// Recurrence choices offered by the form.
enum _Kind { daily, everyOtherDay, weekly, monthly, specificDays }

/// Editable state of one daily time.
class _Slot {
  _Slot({required this.from, required this.to, required this.random});

  LocalTime from;
  LocalTime to;
  bool random;

  TimeSlot toTimeSlot() => random ? TimeSlot(from: from, to: to) : TimeSlot.at(from);
}

/// Creation and editing of an activity.
class ActivityFormScreen extends ConsumerStatefulWidget {
  const ActivityFormScreen({
    super.key,
    this.activityId,
    this.initialName,
    this.initialDate,
    this.initialTime,
  });

  /// The activity to edit; `null` creates a new one.
  final String? activityId;

  /// Pre-filled name (e.g. "Add as activity" from a calendar event).
  final String? initialName;

  /// Pre-filled start date.
  final LocalDate? initialDate;

  /// Pre-filled exact time of the first reminder.
  final LocalTime? initialTime;

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _name = TextEditingController();
  final _notification = TextEditingController();
  bool _initialized = false;
  Activity? _editing;
  String? _nameError;

  _Kind _kind = _Kind.daily;
  late LocalDate _startDate;
  int _weekday = DateTime.monday;
  int _monthDay = 1;
  Set<int> _specificDays = {};
  MonthRepeat _repeat = MonthRepeat.everyMonth;
  List<_Slot> _slots = [];
  int _color = 8;
  bool _partial = false;
  int _reminders = 3;
  LocalTime _until = const LocalTime(21, 0);
  bool _linkGoal = false;
  String? _goalId;
  double _impact = 10;
  ImpactType _impactType = ImpactType.additive;

  @override
  void dispose() {
    _name.dispose();
    _notification.dispose();
    super.dispose();
  }

  /// Fills the state once, from the edited activity or the defaults.
  void _init(Activity? activity) {
    _initialized = true;
    final today = ref.read(todayProvider);
    _startDate = widget.initialDate ?? today;
    _weekday = _startDate.weekday;
    _monthDay = _startDate.day;
    final time = widget.initialTime;
    _slots = [
      if (time == null)
        _Slot(from: const LocalTime(9, 0), to: const LocalTime(10, 0), random: true)
      else
        _Slot(from: time, to: LocalTime.fromMinutes(time.inMinutes + 60), random: false),
    ];
    _name.text = widget.initialName ?? '';
    if (activity == null) return;

    _editing = activity;
    _name.text = activity.name;
    _notification.text = activity.notificationText;
    _startDate = activity.startDate;
    _color = activity.borderColorIndex;
    _slots = [
      for (final s in activity.timeSlots) _Slot(from: s.from, to: s.to, random: !s.isExact),
    ];
    switch (activity.recurrence) {
      case DailyRecurrence():
        _kind = _Kind.daily;
      case EveryOtherDayRecurrence():
        _kind = _Kind.everyOtherDay;
      case WeeklyRecurrence(:final weekday):
        _kind = _Kind.weekly;
        _weekday = weekday;
      case MonthlyRecurrence(:final day):
        _kind = _Kind.monthly;
        _monthDay = day;
      case SpecificDaysRecurrence(:final days, :final repeat):
        _kind = _Kind.specificDays;
        _specificDays = {...days};
        _repeat = repeat;
    }
    final partial = activity.partial;
    if (partial != null) {
      _partial = true;
      _reminders = partial.reminderCount;
      _until = partial.until;
    }
    final link = activity.goalLink;
    if (link != null) {
      _linkGoal = true;
      _goalId = link.goalId;
      _impact = link.impact.toDouble();
      _impactType = link.type;
    }
  }

  Recurrence _recurrence() => switch (_kind) {
    _Kind.daily => const DailyRecurrence(),
    _Kind.everyOtherDay => EveryOtherDayRecurrence(anchor: _startDate),
    _Kind.weekly => WeeklyRecurrence(weekday: _weekday),
    _Kind.monthly => MonthlyRecurrence(day: _monthDay),
    _Kind.specificDays => SpecificDaysRecurrence(
      days: _specificDays,
      repeat: _repeat,
      anchorYear: _startDate.year,
      anchorMonth: _startDate.month,
    ),
  };

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = _name.text.trim();
    final draft = ActivityDraft(
      name: name,
      notificationText: _notification.text.trim().isEmpty ? name : _notification.text.trim(),
      borderColorIndex: _color,
      recurrence: _recurrence(),
      timeSlots: [for (final s in _slots) s.toTimeSlot()],
      startDate: _startDate,
      partial: _partial ? PartialConfig(reminderCount: _reminders, until: _until) : null,
      goalLink: _linkGoal && _goalId != null
          ? GoalLink(goalId: _goalId!, impact: _impact.round(), type: _impactType)
          : null,
    );

    final errors = draft.validate();
    setState(() => _nameError = errors.contains(DraftError.emptyName) ? l10n.errorEmptyName : null);
    if (errors.isNotEmpty) {
      final message = switch (errors.first) {
        DraftError.emptyName => l10n.errorEmptyName,
        DraftError.noDaysSelected => l10n.errorNoDays,
        _ => l10n.errorTimeSlot,
      };
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    final service = ref.read(activityServiceProvider);
    if (_editing == null) {
      await service.create(draft);
    } else {
      await service.update(_editing!, draft);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!_initialized) {
      if (widget.activityId == null) {
        _init(null);
      } else {
        final activities = ref.watch(activitiesByIdProvider).value;
        if (activities == null) return const Scaffold();
        _init(activities[widget.activityId]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing == null ? l10n.newActivity : l10n.editActivity),
        actions: [
          TextButton(onPressed: _save, child: Text(l10n.save)),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          _nameSection(context),
          _recurrenceSection(context),
          _timesSection(context),
          FormSection(
            title: l10n.sectionColor,
            child: BorderColorPicker(
              selected: _color,
              onChanged: (i) => setState(() => _color = i),
            ),
          ),
          _partialSection(context),
          _goalSection(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _save,
              child: Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameSection(BuildContext context) {
    final l10n = context.l10n;
    return FormSection(
      title: l10n.fieldName,
      child: Column(
        children: [
          TextField(
            controller: _name,
            autofocus: _editing == null && (widget.initialName?.isEmpty ?? true),
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.fieldNameHint,
              errorText: _nameError,
              fillColor: context.tokens.page,
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notification,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.fieldNotification,
              hintText: l10n.fieldNotificationHint,
              fillColor: context.tokens.page,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recurrenceSection(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final labels = {
      _Kind.daily: l10n.recurrenceDaily,
      _Kind.everyOtherDay: l10n.recurrenceEveryOtherDay,
      _Kind.weekly: l10n.recurrenceWeekly,
      _Kind.monthly: l10n.recurrenceMonthly,
      _Kind.specificDays: l10n.recurrenceSpecificDays,
    };
    return FormSection(
      title: l10n.sectionRecurrence,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final kind in _Kind.values)
                ChoiceChip(
                  label: Text(labels[kind]!),
                  selected: _kind == kind,
                  onSelected: (_) => setState(() => _kind = kind),
                ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: switch (_kind) {
                _Kind.weekly => WeekdayPicker(
                  selected: _weekday,
                  onChanged: (d) => setState(() => _weekday = d),
                ),
                _Kind.monthly => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MonthDayGrid(
                      selected: {_monthDay},
                      onToggle: (d) => setState(() => _monthDay = d),
                    ),
                    if (_monthDay > 28) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.monthlyClampNote,
                        style: TextStyle(color: t.textMuted, fontSize: 12),
                      ),
                    ],
                  ],
                ),
                _Kind.specificDays => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MonthDayGrid(
                      selected: _specificDays,
                      onToggle: (d) => setState(
                        () => _specificDays.contains(d)
                            ? _specificDays.remove(d)
                            : _specificDays.add(d),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final (repeat, label) in [
                          (MonthRepeat.none, l10n.repeatNone),
                          (MonthRepeat.nextMonth, l10n.repeatNext),
                          (MonthRepeat.everyMonth, l10n.repeatEvery),
                        ])
                          ChoiceChip(
                            label: Text(label),
                            selected: _repeat == repeat,
                            onSelected: (_) => setState(() => _repeat = repeat),
                          ),
                      ],
                    ),
                  ],
                ),
                _ => const SizedBox(width: double.infinity),
              },
            ),
          ),
          const SizedBox(height: 4),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: Text(l10n.startDate),
            // Subtitle, not trailing: the full date can be long.
            subtitle: Text(context.fullDate(_startDate), style: TextStyle(color: t.textMuted)),
            trailing: Icon(Icons.chevron_right, color: t.textMuted),
            onTap: () async {
              final today = ref.read(todayProvider);
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate.toDateTime(),
                firstDate: today.addDays(-365).toDateTime(),
                lastDate: today.addDays(365 * 3).toDateTime(),
              );
              if (picked != null) setState(() => _startDate = LocalDate.fromDateTime(picked));
            },
          ),
        ],
      ),
    );
  }

  Widget _timesSection(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    return FormSection(
      title: l10n.sectionTimes,
      trailing: CountStepper(
        value: _slots.length,
        min: 1,
        max: 12,
        onChanged: (n) => setState(() {
          while (_slots.length < n) {
            final last = _slots.last;
            final start = LocalTime.fromMinutes(last.from.inMinutes + 180);
            final end = LocalTime.fromMinutes(last.to.inMinutes + 180);
            _slots.add(_Slot(from: start, to: end, random: last.random));
          }
          if (_slots.length > n) _slots = _slots.sublist(0, n);
        }),
      ),
      child: Column(
        children: [
          for (final (i, slot) in _slots.indexed)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              decoration: BoxDecoration(
                border: Border.all(color: t.divider),
                borderRadius: BorderRadius.circular(t.radius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.timeSlotLabel(i + 1),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(l10n.timeRandom, style: TextStyle(color: t.textMuted, fontSize: 12)),
                      Switch(
                        value: slot.random,
                        onChanged: (v) => setState(() {
                          slot.random = v;
                          if (v && !slot.to.isAfter(slot.from)) {
                            slot.to = LocalTime.fromMinutes(slot.from.inMinutes + 60);
                          }
                        }),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TimeButton(
                          label: slot.random ? l10n.timeFrom : l10n.timeAt,
                          time: slot.from,
                          onChanged: (v) => setState(() {
                            slot.from = v;
                            if (slot.to.isBefore(v)) slot.to = v;
                          }),
                        ),
                      ),
                      if (slot.random) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: TimeButton(
                            label: l10n.timeTo,
                            time: slot.to,
                            onChanged: (v) =>
                                setState(() => slot.to = v.isBefore(slot.from) ? slot.from : v),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _partialSection(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    return FormSection(
      title: l10n.sectionPartial,
      trailing: Switch(value: _partial, onChanged: (v) => setState(() => _partial = v)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.partialDescription, style: TextStyle(color: t.textMuted, fontSize: 13)),
            if (_partial) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text(l10n.partialReminders)),
                  CountStepper(
                    value: _reminders,
                    min: 0,
                    max: 10,
                    onChanged: (v) => setState(() => _reminders = v),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TimeButton(
                  label: l10n.partialUntil,
                  time: _until,
                  onChanged: (v) => setState(() => _until = v),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _goalSection(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final goals = ref.watch(linkableGoalsProvider).value ?? const [];
    // A link to a goal of a past month is kept as is (it is not in the list,
    // so the dropdown shows nothing selected until the user picks another).
    final dropdownValue = goals.any((g) => g.id == _goalId) ? _goalId : null;

    return FormSection(
      title: l10n.sectionGoal,
      trailing: Switch(
        value: _linkGoal,
        onChanged: goals.isEmpty
            ? null
            : (v) => setState(() {
                _linkGoal = v;
                _goalId ??= goals.first.id;
              }),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.topCenter,
        child: goals.isEmpty
            ? Text(l10n.goalNone, style: TextStyle(color: t.textMuted, fontSize: 13))
            : !_linkGoal
            ? Text(l10n.goalLinkToggle, style: TextStyle(color: t.textMuted, fontSize: 13))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: dropdownValue,
                    decoration: InputDecoration(labelText: l10n.goalPick, fillColor: t.page),
                    items: [
                      for (final g in goals)
                        DropdownMenuItem(
                          value: g.id,
                          child: Text('${g.title} · ${context.monthYear(g.year, g.month)}'),
                        ),
                    ],
                    onChanged: (id) => setState(() => _goalId = id),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(l10n.goalImpact),
                      Expanded(
                        child: Slider(
                          value: _impact,
                          max: 100,
                          divisions: 20,
                          label: l10n.percent(_impact.round()),
                          onChanged: (v) => setState(() => _impact = v),
                        ),
                      ),
                      SizedBox(width: 44, child: Text(l10n.percent(_impact.round()))),
                    ],
                  ),
                  SegmentedButton<ImpactType>(
                    segments: [
                      ButtonSegment(
                        value: ImpactType.additive,
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l10n.impactAdditive),
                      ),
                      ButtonSegment(
                        value: ImpactType.subtractive,
                        icon: const Icon(Icons.remove_rounded),
                        label: Text(l10n.impactSubtractive),
                      ),
                    ],
                    selected: {_impactType},
                    onSelectionChanged: (s) => setState(() => _impactType = s.first),
                  ),
                ],
              ),
      ),
    );
  }
}
