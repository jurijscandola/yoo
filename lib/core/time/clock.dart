import 'local_date.dart';

/// Source of the current time, injected so that logic can be tested.
abstract interface class Clock {
  /// Current instant in the device time zone.
  DateTime now();
}

/// The real device clock.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// A clock frozen at a given instant, for tests.
class FixedClock implements Clock {
  FixedClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;
}

/// Convenience accessors on [Clock].
extension ClockDates on Clock {
  /// Today's date in the device time zone.
  LocalDate today() => LocalDate.fromDateTime(now());
}
