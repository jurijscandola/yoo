import 'package:device_calendar_plus/device_calendar_plus.dart';

import '../domain/external_calendar_source.dart';

/// [ExternalCalendarSource] backed by the device calendars (Android Calendar
/// Provider, iOS EventKit) through device_calendar_plus. Never writes.
class DeviceExternalCalendarSource implements ExternalCalendarSource {
  DeviceExternalCalendarSource({DeviceCalendar? plugin})
    : _plugin = plugin ?? DeviceCalendar.instance;

  final DeviceCalendar _plugin;

  static ExternalCalendarAccess _map(CalendarPermissionStatus status) => switch (status) {
    CalendarPermissionStatus.granted => ExternalCalendarAccess.granted,
    CalendarPermissionStatus.notDetermined => ExternalCalendarAccess.askable,
    // Write-only cannot read events; restricted cannot be changed by the user.
    CalendarPermissionStatus.writeOnly ||
    CalendarPermissionStatus.denied ||
    CalendarPermissionStatus.restricted => ExternalCalendarAccess.denied,
  };

  /// Parses "#RRGGBB" / "#AARRGGBB" into ARGB.
  static int? _color(String? hex) {
    if (hex == null) return null;
    final digits = hex.replaceFirst('#', '');
    final value = int.tryParse(digits, radix: 16);
    if (value == null) return null;
    return digits.length <= 6 ? 0xFF000000 | value : value;
  }

  @override
  Future<ExternalCalendarAccess> access() async => _map(await _plugin.hasPermissions());

  @override
  Future<ExternalCalendarAccess> requestAccess() async => _map(await _plugin.requestPermissions());

  @override
  Future<void> openSystemSettings() => _plugin.openAppSettings();

  @override
  Future<List<ExternalCalendar>> calendars() async {
    final calendars = await _plugin.listCalendars();
    return [
      for (final c in calendars)
        if (!c.hidden)
          ExternalCalendar(
            id: c.id,
            name: c.name,
            account: c.accountName,
            colorArgb: _color(c.colorHex),
          ),
    ];
  }

  @override
  Future<List<ExternalEvent>> eventsBetween(DateTime from, DateTime to) async {
    // Only visible calendars, like the device calendar app.
    final visible = {for (final c in await calendars()) c.id: c};
    final events = await _plugin.listEvents(from, to);
    return [
      for (final e in events)
        if (visible.containsKey(e.calendarId))
          ExternalEvent(
            id: e.instanceId,
            calendarId: e.calendarId,
            title: e.title,
            start: e.startDate,
            end: e.endDate,
            isAllDay: e.isAllDay,
            colorArgb: _color(e.colorHex) ?? visible[e.calendarId]!.colorArgb,
          ),
    ];
  }
}
