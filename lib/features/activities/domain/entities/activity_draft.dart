import '../../../../core/time/local_date.dart';
import 'activity.dart';
import 'recurrence.dart';

/// User input of the activity form, before it becomes an [Activity].
class ActivityDraft {
  const ActivityDraft({
    required this.name,
    required this.notificationText,
    required this.borderColorIndex,
    required this.recurrence,
    required this.timeSlots,
    required this.startDate,
    this.partial,
    this.goalLink,
  });

  /// Pre-fills a draft from an existing activity (edit form).
  factory ActivityDraft.fromActivity(Activity a) => ActivityDraft(
    name: a.name,
    notificationText: a.notificationText,
    borderColorIndex: a.borderColorIndex,
    recurrence: a.recurrence,
    timeSlots: a.timeSlots,
    startDate: a.startDate,
    partial: a.partial,
    goalLink: a.goalLink,
  );

  final String name;
  final String notificationText;
  final int borderColorIndex;
  final Recurrence recurrence;
  final List<TimeSlot> timeSlots;
  final LocalDate startDate;
  final PartialConfig? partial;
  final GoalLink? goalLink;

  /// Validation errors, empty when the draft can be saved.
  List<DraftError> validate() => [
    if (name.trim().isEmpty) DraftError.emptyName,
    if (timeSlots.isEmpty) DraftError.noTimeSlots,
    if (timeSlots.any((s) => s.to.isBefore(s.from))) DraftError.invalidTimeSlot,
    if (recurrence is SpecificDaysRecurrence && (recurrence as SpecificDaysRecurrence).days.isEmpty)
      DraftError.noDaysSelected,
    if (partial != null && partial!.reminderCount < 0) DraftError.invalidReminders,
  ];
}

/// Reasons a draft cannot be saved.
enum DraftError { emptyName, noTimeSlots, invalidTimeSlot, noDaysSelected, invalidReminders }
