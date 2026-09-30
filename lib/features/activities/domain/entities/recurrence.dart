import '../../../../core/time/local_date.dart';

/// When an activity recurs. Each variant answers [occursOn] for a given day.
///
/// The activity's start date is checked by [Activity.isPlannedOn]; recurrences
/// only describe the repeating pattern.
sealed class Recurrence {
  const Recurrence();

  /// Whether the pattern includes [date].
  bool occursOn(LocalDate date);

  /// Serializes to a plain map (used by persistence and export).
  Map<String, Object?> toJson();

  /// Restores a recurrence serialized with [toJson].
  static Recurrence fromJson(Map<String, Object?> json) {
    return switch (json['type']) {
      'once' => OnceRecurrence(date: LocalDate.parse(json['date']! as String)),
      'daily' => const DailyRecurrence(),
      'everyOtherDay' => EveryOtherDayRecurrence(
        anchor: LocalDate.parse(json['anchor']! as String),
      ),
      'weekly' => WeeklyRecurrence(
        weekday: json['weekday']! as int,
        everyWeeks: json['everyWeeks'] as int? ?? 1,
        anchor: switch (json['anchor']) {
          final String a => LocalDate.parse(a),
          _ => null,
        },
      ),
      'monthly' => MonthlyRecurrence(day: json['day']! as int),
      'specificDays' => SpecificDaysRecurrence(
        days: {for (final d in json['days']! as List<Object?>) d! as int},
        repeat: MonthRepeat.values.byName(json['repeat']! as String),
        anchorYear: json['anchorYear']! as int,
        anchorMonth: json['anchorMonth']! as int,
      ),
      final type => throw FormatException('Unknown recurrence type: $type'),
    };
  }
}

/// A single day, with no repetition (e.g. an event imported from a calendar).
class OnceRecurrence extends Recurrence {
  const OnceRecurrence({required this.date});

  final LocalDate date;

  @override
  bool occursOn(LocalDate date) => date == this.date;

  @override
  Map<String, Object?> toJson() => {'type': 'once', 'date': date.toString()};

  @override
  bool operator ==(Object other) => other is OnceRecurrence && other.date == date;

  @override
  int get hashCode => Object.hash('once', date);
}

/// Every day.
class DailyRecurrence extends Recurrence {
  const DailyRecurrence();

  @override
  bool occursOn(LocalDate date) => true;

  @override
  Map<String, Object?> toJson() => {'type': 'daily'};

  @override
  bool operator ==(Object other) => other is DailyRecurrence;

  @override
  int get hashCode => (DailyRecurrence).hashCode;
}

/// Every other day, counting from [anchor] (which is an "on" day).
class EveryOtherDayRecurrence extends Recurrence {
  const EveryOtherDayRecurrence({required this.anchor});

  final LocalDate anchor;

  @override
  bool occursOn(LocalDate date) => anchor.daysUntil(date).isEven;

  @override
  Map<String, Object?> toJson() => {'type': 'everyOtherDay', 'anchor': anchor.toString()};

  @override
  bool operator ==(Object other) => other is EveryOtherDayRecurrence && other.anchor == anchor;

  @override
  int get hashCode => Object.hash('everyOtherDay', anchor);
}

/// The same weekday every [everyWeeks] weeks (ISO: 1 = Monday … 7 = Sunday).
///
/// With [everyWeeks] > 1 the weeks are counted from [anchor] (an "on" day), so
/// the rhythm carries over month boundaries: "every other Saturday" stays two
/// weeks apart whatever the day of the month.
class WeeklyRecurrence extends Recurrence {
  const WeeklyRecurrence({required this.weekday, this.everyWeeks = 1, this.anchor})
    : assert(weekday >= 1 && weekday <= 7),
      assert(everyWeeks >= 1),
      assert(everyWeeks == 1 || anchor != null, 'An interval needs an anchor day');

  final int weekday;
  final int everyWeeks;

  /// A day on which the activity occurs; only used when [everyWeeks] > 1.
  final LocalDate? anchor;

  @override
  bool occursOn(LocalDate date) {
    if (date.weekday != weekday) return false;
    if (everyWeeks == 1) return true;
    // Dart's % is never negative, so days before the anchor work too.
    return anchor!.daysUntil(date) % (7 * everyWeeks) == 0;
  }

  @override
  Map<String, Object?> toJson() => {
    'type': 'weekly',
    'weekday': weekday,
    if (everyWeeks > 1) ...{'everyWeeks': everyWeeks, 'anchor': anchor.toString()},
  };

  @override
  bool operator ==(Object other) =>
      other is WeeklyRecurrence &&
      other.weekday == weekday &&
      other.everyWeeks == everyWeeks &&
      (everyWeeks == 1 || other.anchor == anchor);

  @override
  int get hashCode => Object.hash('weekly', weekday, everyWeeks, everyWeeks == 1 ? null : anchor);
}

/// One day per month. Days past the end of a short month fall on its last day
/// (e.g. day 31 → 30 April, 28/29 February), so no month is skipped.
class MonthlyRecurrence extends Recurrence {
  const MonthlyRecurrence({required this.day}) : assert(day >= 1 && day <= 31);

  final int day;

  @override
  bool occursOn(LocalDate date) {
    final effective = day > date.daysInMonth ? date.daysInMonth : day;
    return date.day == effective;
  }

  @override
  Map<String, Object?> toJson() => {'type': 'monthly', 'day': day};

  @override
  bool operator ==(Object other) => other is MonthlyRecurrence && other.day == day;

  @override
  int get hashCode => Object.hash('monthly', day);
}

/// How a selection of specific days of the month repeats.
enum MonthRepeat {
  /// Only in the anchor month.
  none,

  /// In the anchor month and in the following one.
  nextMonth,

  /// In the anchor month and every month after it.
  everyMonth,
}

/// A selection of days of the month (e.g. 1, 15, 28), starting from the anchor
/// month. Days that do not exist in a month (e.g. 31 in April) are skipped.
class SpecificDaysRecurrence extends Recurrence {
  const SpecificDaysRecurrence({
    required this.days,
    required this.repeat,
    required this.anchorYear,
    required this.anchorMonth,
  });

  final Set<int> days;
  final MonthRepeat repeat;
  final int anchorYear;
  final int anchorMonth;

  @override
  bool occursOn(LocalDate date) {
    final offset = LocalDate(anchorYear, anchorMonth, 1).monthsUntil(date);
    final monthIncluded = switch (repeat) {
      MonthRepeat.none => offset == 0,
      MonthRepeat.nextMonth => offset == 0 || offset == 1,
      MonthRepeat.everyMonth => offset >= 0,
    };
    return monthIncluded && days.contains(date.day);
  }

  @override
  Map<String, Object?> toJson() => {
    'type': 'specificDays',
    'days': (days.toList()..sort()),
    'repeat': repeat.name,
    'anchorYear': anchorYear,
    'anchorMonth': anchorMonth,
  };

  @override
  bool operator ==(Object other) =>
      other is SpecificDaysRecurrence &&
      other.repeat == repeat &&
      other.anchorYear == anchorYear &&
      other.anchorMonth == anchorMonth &&
      other.days.length == days.length &&
      other.days.containsAll(days);

  @override
  int get hashCode =>
      Object.hash('specificDays', repeat, anchorYear, anchorMonth, Object.hashAllUnordered(days));
}
