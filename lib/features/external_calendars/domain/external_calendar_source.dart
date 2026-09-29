/// A calendar of the device (Google, Exchange, local…), read only.
class ExternalCalendar {
  const ExternalCalendar({required this.id, required this.name, this.account, this.colorArgb});

  final String id;
  final String name;

  /// Account the calendar belongs to, e.g. an e-mail address.
  final String? account;

  /// Calendar color as ARGB, when the platform provides one.
  final int? colorArgb;
}

/// One event (or one instance of a recurring event) of an external calendar.
class ExternalEvent {
  const ExternalEvent({
    required this.id,
    required this.calendarId,
    required this.title,
    required this.start,
    required this.end,
    required this.isAllDay,
    this.colorArgb,
  });

  /// Unique per instance (recurring events share their series id).
  final String id;
  final String calendarId;
  final String title;

  /// Local start and end. For all-day events only the date matters.
  final DateTime start;
  final DateTime end;
  final bool isAllDay;

  /// Event color as ARGB, falling back to the calendar color.
  final int? colorArgb;
}

/// Whether the app may read the device calendars.
enum ExternalCalendarAccess {
  granted,

  /// Not granted yet, the system dialog can still be shown.
  askable,

  /// Denied for good: only the system settings can change it.
  denied,
}

/// Read-only access to external calendars. Implemented with the device
/// calendars today; direct Google/Microsoft APIs can implement it later.
abstract interface class ExternalCalendarSource {
  Future<ExternalCalendarAccess> access();

  /// Shows the system permission dialog when possible.
  Future<ExternalCalendarAccess> requestAccess();

  /// Opens the app page of the system settings.
  Future<void> openSystemSettings();

  /// Every visible calendar of the device.
  Future<List<ExternalCalendar>> calendars();

  /// Events overlapping `[from, to)`, sorted by start.
  Future<List<ExternalEvent>> eventsBetween(DateTime from, DateTime to);
}

/// Source without calendars: tests, and platforms without calendar access.
class EmptyExternalCalendarSource implements ExternalCalendarSource {
  const EmptyExternalCalendarSource();

  @override
  Future<ExternalCalendarAccess> access() async => ExternalCalendarAccess.granted;

  @override
  Future<ExternalCalendarAccess> requestAccess() async => ExternalCalendarAccess.granted;

  @override
  Future<void> openSystemSettings() async {}

  @override
  Future<List<ExternalCalendar>> calendars() async => const [];

  @override
  Future<List<ExternalEvent>> eventsBetween(DateTime from, DateTime to) async => const [];
}
