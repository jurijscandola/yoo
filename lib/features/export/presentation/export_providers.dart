import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../activities/presentation/activity_providers.dart';
import '../../calendar/presentation/calendar_providers.dart';
import '../../goals/presentation/goal_providers.dart';
import '../domain/export_destination.dart';
import '../domain/month_report.dart';

/// Where exports go. Does nothing by default; `main` overrides it with the
/// share sheet.
final exportDestinationProvider = Provider<ExportDestination>(
  (ref) => const NoopExportDestination(),
);

/// The report of a month, live.
final monthReportProvider = FutureProvider.autoDispose.family<MonthReport, YearMonth>((
  ref,
  month,
) async {
  final (year, m) = month;
  final activities = await ref.watch(activitiesByIdProvider.future);
  final occurrences = await ref.watch(monthOccurrencesProvider(month).future);
  final goals = await ref.watch(monthGoalsProgressProvider(month).future);
  return MonthReport.build(
    year: year,
    month: m,
    today: ref.watch(todayProvider),
    activitiesById: activities,
    occurrences: occurrences,
    goals: goals,
  );
});
