import '../../../../core/time/local_date.dart';
import '../../../../core/time/local_time.dart';
import 'recurrence.dart';

/// A recurring activity created by the user.
class Activity {
  const Activity({
    required this.id,
    required this.name,
    required this.notificationText,
    required this.borderColorIndex,
    required this.recurrence,
    required this.timeSlots,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
    this.partial,
    this.goalLink,
    this.deletedAt,
  }) : assert(timeSlots.length > 0, 'An activity needs at least one time slot');

  /// UUID, stable across devices (ready for future sync).
  final String id;

  final String name;

  /// Body of the reminder notifications.
  final String notificationText;

  /// Index into the 16-color border palette.
  final int borderColorIndex;

  final Recurrence recurrence;

  /// One slot per time the activity must be done on a planned day.
  final List<TimeSlot> timeSlots;

  /// First day the activity can be planned on.
  final LocalDate startDate;

  /// Partial-completion settings; `null` for plain done/not-done activities.
  final PartialConfig? partial;

  /// Optional contribution to a monthly goal.
  final GoalLink? goalLink;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Soft-delete marker: deleted activities are no longer planned, but their
  /// history stays for summaries, export and goals.
  final DateTime? deletedAt;

  /// How many times the activity must be done on a planned day.
  int get timesPerDay => timeSlots.length;

  bool get isPartial => partial != null;
  bool get isDeleted => deletedAt != null;

  /// Whether the activity should appear on [date] according to its recurrence.
  bool isPlannedOn(LocalDate date) =>
      !isDeleted && !date.isBefore(startDate) && recurrence.occursOn(date);

  Activity copyWith({
    String? name,
    String? notificationText,
    int? borderColorIndex,
    Recurrence? recurrence,
    List<TimeSlot>? timeSlots,
    LocalDate? startDate,
    PartialConfig? Function()? partial,
    GoalLink? Function()? goalLink,
    DateTime? updatedAt,
    DateTime? Function()? deletedAt,
  }) {
    return Activity(
      id: id,
      name: name ?? this.name,
      notificationText: notificationText ?? this.notificationText,
      borderColorIndex: borderColorIndex ?? this.borderColorIndex,
      recurrence: recurrence ?? this.recurrence,
      timeSlots: timeSlots ?? this.timeSlots,
      startDate: startDate ?? this.startDate,
      partial: partial != null ? partial() : this.partial,
      goalLink: goalLink != null ? goalLink() : this.goalLink,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }
}

/// A time window in which one reminder fires at a random minute.
/// `from == to` means an exact time.
class TimeSlot {
  const TimeSlot({required this.from, required this.to});

  /// An exact-time slot.
  const TimeSlot.at(LocalTime time) : from = time, to = time;

  final LocalTime from;
  final LocalTime to;

  bool get isExact => from == to;

  Map<String, Object?> toJson() => {'from': from.toString(), 'to': to.toString()};

  factory TimeSlot.fromJson(Map<String, Object?> json) => TimeSlot(
    from: LocalTime.parse(json['from']! as String),
    to: LocalTime.parse(json['to']! as String),
  );

  @override
  bool operator ==(Object other) => other is TimeSlot && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

/// Settings of an activity whose completion is a percentage.
class PartialConfig {
  const PartialConfig({required this.reminderCount, required this.until});

  /// Extra reminders sent while the activity is below 100%.
  final int reminderCount;

  /// Reminders are spread evenly from the last slot until this time.
  final LocalTime until;

  Map<String, Object?> toJson() => {'reminderCount': reminderCount, 'until': until.toString()};

  factory PartialConfig.fromJson(Map<String, Object?> json) => PartialConfig(
    reminderCount: json['reminderCount']! as int,
    until: LocalTime.parse(json['until']! as String),
  );
}

/// Whether completing a linked activity raises or lowers the goal.
enum ImpactType { additive, subtractive }

/// Link between an activity and a monthly goal.
class GoalLink {
  const GoalLink({required this.goalId, required this.impact, required this.type})
    : assert(impact >= 0 && impact <= 100);

  final String goalId;

  /// Percentage points applied to the goal per full completion (0–100).
  final int impact;

  final ImpactType type;

  /// Signed contribution of a full completion.
  int get signedImpact => type == ImpactType.additive ? impact : -impact;

  Map<String, Object?> toJson() => {'goalId': goalId, 'impact': impact, 'type': type.name};

  factory GoalLink.fromJson(Map<String, Object?> json) => GoalLink(
    goalId: json['goalId']! as String,
    impact: json['impact']! as int,
    type: ImpactType.values.byName(json['type']! as String),
  );
}
