import '../core/time/local_date.dart';
import '../core/time/local_time.dart';

/// Route paths of the app, kept in one place.
abstract final class Routes {
  static const calendar = '/calendar';
  static const home = '/home';
  static const goals = '/goals';
  static const settings = '/settings';
  static const externalCalendars = '/settings/calendars';
  static const export = '/settings/export';
  static const personalization = '/settings/personalization';
  static const appIcon = '/settings/personalization/icon';

  /// Activity creation, optionally pre-filled with a [name], a start [date]
  /// and a [time] of day.
  static String newActivity({String? name, LocalDate? date, LocalTime? time}) => Uri(
    path: '/activity/new',
    queryParameters: {'name': ?name, 'date': ?date?.toString(), 'time': ?time?.toString()},
  ).toString();

  static String editActivity(String id) => '/activity/$id/edit';

  /// Daily summary of [date].
  static String day(LocalDate date) => '/day/$date';
}
