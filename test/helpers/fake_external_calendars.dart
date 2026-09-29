import 'package:yoo/features/external_calendars/domain/external_calendar_source.dart';

/// Device calendars under the test's control; records permission requests.
class FakeExternalCalendarSource implements ExternalCalendarSource {
  FakeExternalCalendarSource({
    this.currentAccess = ExternalCalendarAccess.granted,
    this.grantOnRequest = true,
    List<ExternalCalendar>? calendars,
    List<ExternalEvent>? events,
  }) : calendarList = calendars ?? const [],
       events = events ?? const [];

  ExternalCalendarAccess currentAccess;
  bool grantOnRequest;
  final List<ExternalCalendar> calendarList;
  final List<ExternalEvent> events;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<ExternalCalendarAccess> access() async => currentAccess;

  @override
  Future<ExternalCalendarAccess> requestAccess() async {
    requests++;
    currentAccess = grantOnRequest ? ExternalCalendarAccess.granted : ExternalCalendarAccess.denied;
    return currentAccess;
  }

  @override
  Future<void> openSystemSettings() async => settingsOpened++;

  @override
  Future<List<ExternalCalendar>> calendars() async => calendarList;

  @override
  Future<List<ExternalEvent>> eventsBetween(DateTime from, DateTime to) async => [
    for (final e in events)
      if (e.start.isBefore(to) && e.end.isAfter(from)) e,
  ];
}
