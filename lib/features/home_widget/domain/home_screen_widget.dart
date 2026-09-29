import 'widget_snapshot.dart';

/// The home screen widget of the platform. Android draws it with Glance;
/// iOS will implement it with WidgetKit (not yet: the no-op is used there).
abstract interface class HomeScreenWidget {
  /// Stores [snapshot] for the widget, redraws it, and asks the system to
  /// redraw it again at each of [redrawAt] (midnights: the widget switches to
  /// the next day of the snapshot by itself).
  Future<void> publish(WidgetSnapshot snapshot, {required List<DateTime> redrawAt});
}

/// Widget that does nothing: tests, and platforms without a widget yet.
class NoopHomeScreenWidget implements HomeScreenWidget {
  const NoopHomeScreenWidget();

  @override
  Future<void> publish(WidgetSnapshot snapshot, {required List<DateTime> redrawAt}) async {}
}
