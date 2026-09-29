import '../../../core/time/local_date.dart';

/// Everything the home screen widget draws, computed by the app and read by
/// the native widget (Glance on Android; WidgetKit later on iOS).
///
/// It holds today and tomorrow: at midnight the native side switches to the
/// day matching the device date without running any Dart code.
class WidgetSnapshot {
  const WidgetSnapshot({required this.colors, required this.days, required this.staleText});

  final WidgetColors colors;
  final List<WidgetDay> days;

  /// Shown when no day matches the device date (the app has not run for a
  /// while): tapping opens the app, which refreshes the widget.
  final String staleText;

  Map<String, Object?> toJson() => {
    'version': 1,
    'colors': colors.toJson(),
    'days': [for (final d in days) d.toJson()],
    'staleText': staleText,
  };
}

/// Theme colors as ARGB integers.
class WidgetColors {
  const WidgetColors({
    required this.page,
    required this.surface,
    required this.card,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.success,
  });

  final int page;
  final int surface;
  final int card;
  final int text;
  final int textMuted;
  final int accent;
  final int success;

  Map<String, Object?> toJson() => {
    'page': page,
    'surface': surface,
    'card': card,
    'text': text,
    'textMuted': textMuted,
    'accent': accent,
    'success': success,
  };
}

/// One day of the widget: header texts and the activities still to do.
class WidgetDay {
  const WidgetDay({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.emptyText,
    required this.items,
  });

  final LocalDate date;

  /// e.g. "Today".
  final String title;

  /// e.g. "Wednesday, September 30".
  final String subtitle;

  /// Shown when [items] is empty ("All done for today" / "Nothing planned").
  final String emptyText;

  final List<WidgetItem> items;

  Map<String, Object?> toJson() => {
    'date': date.toString(),
    'title': title,
    'subtitle': subtitle,
    'emptyText': emptyText,
    'items': [for (final i in items) i.toJson()],
  };
}

/// An activity still to do, with the action a tap performs.
class WidgetItem {
  const WidgetItem({
    required this.activityId,
    required this.name,
    required this.borderColor,
    required this.action,
    this.detail,
  });

  final String activityId;
  final String name;

  /// e.g. "1/3" or "40%".
  final String? detail;

  /// ARGB border color of the activity.
  final int borderColor;

  /// Notification action id applied on tap (see `ReminderActions`).
  final String action;

  Map<String, Object?> toJson() => {
    'activityId': activityId,
    'name': name,
    'detail': detail,
    'borderColor': borderColor,
    'action': action,
  };
}

/// Link opened by a tap on a widget card: `yoo://complete?...`.
abstract final class WidgetLinks {
  static const scheme = 'yoo';

  static Uri complete({
    required String activityId,
    required LocalDate date,
    required String action,
  }) => Uri(
    scheme: scheme,
    host: 'complete',
    queryParameters: {'activity': activityId, 'date': date.toString(), 'action': action},
  );

  /// Opening the app on Home (header tap).
  static final home = Uri(scheme: scheme, host: 'home');

  /// Parses a [complete] link; `null` for anything else.
  static ({String activityId, LocalDate date, String action})? parseComplete(Uri? uri) {
    if (uri == null || uri.scheme != scheme || uri.host != 'complete') return null;
    final p = uri.queryParameters;
    final activity = p['activity'];
    final date = p['date'];
    final action = p['action'];
    if (activity == null || date == null || action == null) return null;
    try {
      return (activityId: activity, date: LocalDate.parse(date), action: action);
    } catch (_) {
      // Malformed date: not a link of ours.
      return null;
    }
  }
}
