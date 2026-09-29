import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/local_date.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/external_calendar_source.dart';

/// The external calendars. Empty by default (tests); `main` overrides it with
/// the device calendars.
final externalCalendarSourceProvider = Provider<ExternalCalendarSource>(
  (ref) => const EmptyExternalCalendarSource(),
);

/// Current permission to read the device calendars. Invalidated on resume
/// (it can be changed in the system settings).
final externalCalendarAccessProvider = FutureProvider.autoDispose<ExternalCalendarAccess>(
  (ref) => ref.watch(externalCalendarSourceProvider).access(),
);

/// Every calendar of the device (for the choice in Settings).
final externalCalendarsProvider = FutureProvider.autoDispose<List<ExternalCalendar>>((ref) async {
  final access = await ref.watch(externalCalendarAccessProvider.future);
  if (access != ExternalCalendarAccess.granted) return const [];
  return ref.watch(externalCalendarSourceProvider).calendars();
});

/// Events of the shown calendars on [date]: all-day ones first, then by start.
/// Empty while the feature is off or the permission is missing. Invalidated
/// on resume, as calendars change outside the app.
final externalEventsOnProvider = FutureProvider.autoDispose.family<List<ExternalEvent>, LocalDate>((
  ref,
  date,
) async {
  final config = ref.watch(currentSettingsProvider.select((s) => s.externalCalendars));
  if (!config.enabled) return const [];
  final access = await ref.watch(externalCalendarAccessProvider.future);
  if (access != ExternalCalendarAccess.granted) return const [];
  final start = date.toDateTime();
  final events = await ref
      .watch(externalCalendarSourceProvider)
      .eventsBetween(start, date.addDays(1).toDateTime());
  return sortedForDay([
    for (final e in events)
      if (!config.hiddenCalendarIds.contains(e.calendarId)) e,
  ]);
});

/// All-day events first, then timed ones by start time, then by title.
List<ExternalEvent> sortedForDay(Iterable<ExternalEvent> events) {
  final list = events.toList();
  list.sort((a, b) {
    if (a.isAllDay != b.isAllDay) return a.isAllDay ? -1 : 1;
    final byStart = a.start.compareTo(b.start);
    return byStart != 0 ? byStart : a.title.compareTo(b.title);
  });
  return list;
}
