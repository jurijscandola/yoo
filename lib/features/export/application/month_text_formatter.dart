import '../../../core/time/local_date.dart';
import '../../../l10n/l10n.dart';
import '../../activities/domain/entities/occurrence.dart';
import '../../activities/domain/services/occurrence_planner.dart';
import '../domain/month_report.dart';

/// Turns a [MonthReport] into the plain text of the exported file.
///
/// Dates are formatted by the caller (they depend on the locale), so the
/// formatter stays independent of Flutter's localization context.
class MonthTextFormatter {
  const MonthTextFormatter({
    required this.l10n,
    required this.monthLabel,
    required this.dayLabel,
    required this.exportedOn,
  });

  final AppLocalizations l10n;

  /// e.g. "September 2026".
  final String monthLabel;

  /// e.g. "Tuesday 29 September 2026".
  final String Function(LocalDate date) dayLabel;

  /// When the export was made, already formatted.
  final String exportedOn;

  String format(MonthReport report) {
    final out = StringBuffer()
      ..writeln(l10n.reportTitle(monthLabel))
      ..writeln(l10n.reportExportedOn(exportedOn))
      ..writeln()
      ..writeln(l10n.reportGoals);
    if (report.goals.isEmpty) out.writeln('  ${l10n.reportNoGoals}');
    for (final g in report.goals) {
      out.writeln('  • ${g.goal.title} — ${l10n.percent(g.progress.round())}');
    }

    out
      ..writeln()
      ..writeln(l10n.reportActivities);
    if (report.days.isEmpty) out.writeln('  ${l10n.reportNoActivities}');
    for (final day in report.days) {
      out.writeln(dayLabel(day.date));
      for (final entry in day.entries) {
        out.writeln('  ${_line(entry)}');
      }
      out.writeln();
    }
    if (report.days.isNotEmpty) out.writeln(l10n.reportTotal(report.completed, report.total));
    // Windows editors (Notepad) expect CRLF; every other one accepts it.
    return out.toString().replaceAll('\n', '\r\n');
  }

  /// "✅ Vitamins — 2/2", "❌ Walk — Moved to the next day", "⏳ Read — 40%".
  String _line(DayEntry entry) {
    final o = entry.occurrence;
    final activity = entry.activity;
    final symbol = switch (o?.status) {
      OccurrenceStatus.completed => '✅',
      OccurrenceStatus.missed => '❌',
      _ => '⏳',
    };
    final details = [
      if (activity.isPartial && o != null) l10n.percent(o.progress),
      if (!activity.isPartial && activity.timesPerDay > 1 && o != null)
        l10n.timesDone(o.completedCount, activity.timesPerDay),
      if (o?.resolution == MissedResolution.moved) l10n.summaryMoved,
      if (o?.retroactive ?? false) l10n.summaryCompletedLater,
    ];
    return ['$symbol ${activity.name}', if (details.isNotEmpty) details.join(', ')].join(' — ');
  }
}
