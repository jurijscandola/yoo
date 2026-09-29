import '../core/time/local_date.dart';

/// Route paths of the app, kept in one place.
abstract final class Routes {
  static const calendar = '/calendar';
  static const home = '/home';
  static const goals = '/goals';
  static const settings = '/settings';

  /// Activity creation, optionally pre-filled with a [name] and a start [date].
  static String newActivity({String? name, LocalDate? date}) => Uri(
    path: '/activity/new',
    queryParameters: {'name': ?name, 'date': ?date?.toString()},
  ).toString();

  static String editActivity(String id) => '/activity/$id/edit';

  /// Daily summary of [date].
  static String day(LocalDate date) => '/day/$date';
}
