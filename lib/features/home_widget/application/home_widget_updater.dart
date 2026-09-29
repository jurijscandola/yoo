import 'package:flutter/widgets.dart' show Locale;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/yoo_palettes.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../core/time/clock.dart';
import '../../../l10n/l10n.dart';
import '../../activities/domain/repositories/activity_repository.dart';
import '../../activities/domain/repositories/occurrence_repository.dart';
import '../../activities/domain/services/occurrence_planner.dart';
import '../../reminders/domain/reminder_gateway.dart';
import '../../settings/domain/settings_repository.dart';
import '../domain/home_screen_widget.dart';
import '../domain/widget_snapshot.dart';

/// Builds the widget snapshot from the stored data and publishes it.
///
/// Reads repositories directly (not UI providers) so that it also runs in
/// background isolates: notification actions, widget taps, periodic task.
class HomeWidgetUpdater {
  HomeWidgetUpdater({
    required this._activities,
    required this._occurrences,
    required this._settings,
    required this._clock,
    required this._widget,
    this._planner = const OccurrencePlanner(),
  });

  final ActivityRepository _activities;
  final OccurrenceRepository _occurrences;
  final SettingsRepository _settings;
  final Clock _clock;
  final HomeScreenWidget _widget;
  final OccurrencePlanner _planner;

  /// How many activities a day may list (a widget shows a handful anyway).
  static const maxItems = 20;

  Future<void> update() async {
    final settings = await _settings.load();
    final locale = Locale(settings.localeCode ?? 'en');
    final l10n = lookupAppLocalizations(locale);
    await initializeDateFormatting(locale.toLanguageTag());
    // Short weekday, full month ("Wed, September 30"): fits narrow widgets.
    final dateFormat = DateFormat.E(
      locale.toLanguageTag(),
    ).addPattern(DateFormat.MMMMd(locale.toLanguageTag()).pattern, ', ');
    final tokens = YooTokens.fromConfig(settings.theme);

    final today = _clock.today();
    final byId = {for (final a in await _activities.getAll(includeDeleted: true)) a.id: a};
    final days = <WidgetDay>[];
    for (final date in [today, today.addDays(1)]) {
      final entries = _planner.entriesOn(
        date: date,
        today: today,
        activitiesById: byId,
        storedOnDate: await _occurrences.getBetween(date, date),
      );
      final open = entries.where((e) => e.occurrence == null || e.occurrence!.isOpen).toList();
      days.add(
        WidgetDay(
          date: date,
          // Whichever day is on screen, it is "today" when it is shown.
          title: l10n.today,
          subtitle: _capitalize(dateFormat.format(date.toDateTime())),
          emptyText: entries.isNotEmpty && open.isEmpty ? l10n.homeAllDone : l10n.homeEmpty,
          items: [
            for (final e in open.take(maxItems))
              WidgetItem(
                activityId: e.activity.id,
                name: e.activity.name,
                detail: e.activity.isPartial
                    ? (e.occurrence == null ? null : l10n.percent(e.occurrence!.progress))
                    : e.activity.timesPerDay > 1
                    ? l10n.timesDone(e.occurrence?.completedCount ?? 0, e.activity.timesPerDay)
                    : null,
                borderColor: YooPalettes.borderColor(e.activity.borderColorIndex).toARGB32(),
                action: e.activity.isPartial ? ReminderActions.full : ReminderActions.done,
              ),
          ],
        ),
      );
    }

    final snapshot = WidgetSnapshot(
      colors: WidgetColors(
        page: tokens.page.toARGB32(),
        surface: tokens.surface.toARGB32(),
        card: tokens.card.toARGB32(),
        text: tokens.text.toARGB32(),
        textMuted: tokens.textMuted.toARGB32(),
        accent: tokens.accent.toARGB32(),
        success: tokens.success.toARGB32(),
      ),
      days: days,
      staleText: l10n.widgetStale,
    );
    // Redraw just after the next two midnights: tomorrow is in the snapshot,
    // the day after shows the "open the app" text until the app refreshes.
    final midnight = today.addDays(1).toDateTime().add(const Duration(seconds: 1));
    await _widget.publish(
      snapshot,
      redrawAt: [midnight, today.addDays(2).toDateTime().add(const Duration(seconds: 1))],
    );
  }

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
