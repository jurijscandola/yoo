/// A wall-clock time of day with minute precision (e.g. 08:30).
class LocalTime implements Comparable<LocalTime> {
  const LocalTime(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60);

  /// Builds a time from minutes since midnight (clamped to the day).
  factory LocalTime.fromMinutes(int minutes) {
    final m = minutes.clamp(0, 24 * 60 - 1);
    return LocalTime(m ~/ 60, m % 60);
  }

  /// Parses `HH:mm` (the persistence format).
  factory LocalTime.parse(String value) {
    final parts = value.split(':');
    return LocalTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  final int hour;
  final int minute;

  /// Last minute of the day, 23:59.
  static const endOfDay = LocalTime(23, 59);

  /// Minutes since midnight.
  int get inMinutes => hour * 60 + minute;

  bool isBefore(LocalTime other) => inMinutes < other.inMinutes;
  bool isAfter(LocalTime other) => inMinutes > other.inMinutes;

  @override
  int compareTo(LocalTime other) => inMinutes.compareTo(other.inMinutes);

  @override
  bool operator ==(Object other) =>
      other is LocalTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => inMinutes;

  /// `HH:mm`.
  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
