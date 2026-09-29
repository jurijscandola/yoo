/// A calendar date without time or time zone (e.g. 2026-09-29).
///
/// Activities are planned on wall-clock days, so dates are kept separate from
/// instants. Arithmetic goes through UTC to be immune to DST shifts.
class LocalDate implements Comparable<LocalDate> {
  LocalDate(int year, int month, int day) : this._fromUtc(DateTime.utc(year, month, day));

  LocalDate._fromUtc(DateTime utc) : year = utc.year, month = utc.month, day = utc.day;

  /// The date part of [dateTime], read in its own time zone.
  factory LocalDate.fromDateTime(DateTime dateTime) =>
      LocalDate(dateTime.year, dateTime.month, dateTime.day);

  /// Parses an ISO `yyyy-MM-dd` string (the persistence format).
  factory LocalDate.parse(String iso) {
    final parts = iso.split('-');
    return LocalDate(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  final int year;
  final int month;
  final int day;

  DateTime get _utc => DateTime.utc(year, month, day);

  /// ISO weekday: 1 = Monday … 7 = Sunday.
  int get weekday => _utc.weekday;

  /// Number of days in this date's month.
  int get daysInMonth => DateTime.utc(year, month + 1, 0).day;

  /// First day of this date's month.
  LocalDate get firstOfMonth => LocalDate(year, month, 1);

  /// Last day of this date's month.
  LocalDate get lastOfMonth => LocalDate(year, month, daysInMonth);

  /// Returns the date [days] days later (negative values go back).
  LocalDate addDays(int days) => LocalDate(year, month, day + days);

  /// Returns the first day of the month [months] months later.
  LocalDate addMonths(int months) => LocalDate(year, month + months, 1);

  /// Whole days from this date to [other] (positive if [other] is later).
  int daysUntil(LocalDate other) => other._utc.difference(_utc).inDays;

  /// Months from this date's month to [other]'s month.
  int monthsUntil(LocalDate other) => (other.year - year) * 12 + (other.month - month);

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  /// Whether both dates fall in the same month of the same year.
  bool isSameMonth(LocalDate other) => year == other.year && month == other.month;

  /// Local midnight of this date, as a [DateTime] in the device time zone.
  DateTime toDateTime() => DateTime(year, month, day);

  /// Iterates every date from this one to [end], both included.
  Iterable<LocalDate> rangeTo(LocalDate end) sync* {
    for (var d = this; !d.isAfter(end); d = d.addDays(1)) {
      yield d;
    }
  }

  @override
  int compareTo(LocalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is LocalDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// ISO `yyyy-MM-dd`.
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
