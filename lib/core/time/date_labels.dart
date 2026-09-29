import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';
import 'local_date.dart';
import 'local_time.dart';

/// Localized, human-friendly labels for dates and times.
extension DateLabels on BuildContext {
  String get _locale => Localizations.localeOf(this).toLanguageTag();

  /// "Today", "Yesterday", "Tomorrow" or null for other days.
  String? relativeDayName(LocalDate date, LocalDate today) {
    final diff = today.daysUntil(date);
    return switch (diff) {
      0 => l10n.today,
      -1 => l10n.yesterday,
      1 => l10n.tomorrow,
      _ => null,
    };
  }

  /// Full weekday name, e.g. "Tuesday".
  String weekdayName(LocalDate date) =>
      _capitalize(DateFormat.EEEE(_locale).format(date.toDateTime()));

  /// e.g. "29 September" / "29 settembre".
  String dayMonth(LocalDate date) => DateFormat.MMMMd(_locale).format(date.toDateTime());

  /// e.g. "Tuesday 29 September 2026".
  String fullDate(LocalDate date) =>
      _capitalize(DateFormat.yMMMMEEEEd(_locale).format(date.toDateTime()));

  /// e.g. "September 2026".
  String monthYear(int year, int month) =>
      _capitalize(DateFormat.yMMMM(_locale).format(DateTime(year, month)));

  /// Short weekday name for ISO [weekday] (1 = Monday), e.g. "Mon".
  String shortWeekday(int weekday) => _capitalize(
    DateFormat.E(_locale).format(DateTime(2024, 1, weekday)),
  ); // 2024-01-01 is a Monday.

  /// e.g. "08:30" (24h) or "8:30 AM" depending on the locale.
  String timeLabel(LocalTime time) =>
      DateFormat.jm(_locale).format(DateTime(2000, 1, 1, time.hour, time.minute));

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
