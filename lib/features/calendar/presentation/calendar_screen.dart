import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../core/time/date_labels.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/l10n.dart';
import '../../goals/presentation/month_goals_section.dart';
import '../domain/day_mark.dart';
import 'calendar_providers.dart';

/// Calendar tab: a navigable month (a dot under each day summarizes it) and
/// the goals of that month. Tapping a day opens its summary, which lists what
/// is planned for future days.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  /// First day of the month on screen; `null` means the current month.
  LocalDate? _month;
  PageController? _pages;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final today = ref.watch(todayProvider);
    final month = _month ?? today.firstOfMonth;
    final marks = ref.watch(monthMarksProvider((month.year, month.month))).value ?? const {};
    final firstWeekday = MaterialLocalizations.of(context).firstDayOfWeekIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.navCalendar,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: t.surface,
              borderRadius: BorderRadius.circular(t.radius + 4),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: l10n.previousMonth,
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => _pages?.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            // Tapping the title goes back to the current month.
                            onTap: () => setState(() => _month = null),
                            child: Text(
                              context.monthYear(month.year, month.month),
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.nextMonth,
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => _pages?.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          ),
                        ),
                      ],
                    ),
                    TableCalendar<void>(
                      firstDay: DateTime.utc(2000),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: month.toDateTime(),
                      currentDay: today.toDateTime(),
                      locale: Localizations.localeOf(context).toLanguageTag(),
                      startingDayOfWeek: firstWeekday == 0
                          ? StartingDayOfWeek.sunday
                          : StartingDayOfWeek.monday,
                      headerVisible: false,
                      availableCalendarFormats: const {CalendarFormat.month: ''},
                      availableGestures: AvailableGestures.horizontalSwipe,
                      rowHeight: 50,
                      daysOfWeekHeight: 24,
                      onCalendarCreated: (controller) => _pages = controller,
                      onPageChanged: (focused) =>
                          setState(() => _month = LocalDate(focused.year, focused.month, 1)),
                      onDaySelected: (day, _) =>
                          context.push(Routes.day(LocalDate(day.year, day.month, day.day))),
                      calendarBuilders: CalendarBuilders(
                        dowBuilder: (context, day) => Center(
                          child: Text(
                            context.shortWeekday(day.weekday),
                            style: TextStyle(color: t.textMuted, fontSize: 12),
                          ),
                        ),
                        defaultBuilder: (context, day, _) => _DayCell(day: day, marks: marks),
                        todayBuilder: (context, day, _) =>
                            _DayCell(day: day, marks: marks, isToday: true),
                        outsideBuilder: (context, day, _) =>
                            _DayCell(day: day, marks: const {}, outside: true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          MonthGoalsSection(year: month.year, month: month.month),
        ],
      ),
    );
  }
}

/// A day number with a dot summarizing it (see [DayMark]).
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.marks,
    this.isToday = false,
    this.outside = false,
  });

  final DateTime day;
  final Map<LocalDate, DayMark> marks;
  final bool isToday;
  final bool outside;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final mark = marks[LocalDate(day.year, day.month, day.day)] ?? DayMark.none;
    final dot = switch (mark) {
      DayMark.none => null,
      DayMark.planned => t.textMuted,
      DayMark.done => t.success,
      DayMark.missed => t.danger,
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: isToday ? BoxDecoration(color: t.accent, shape: BoxShape.circle) : null,
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: isToday
                  ? t.onAccent
                  : outside
                  ? t.textMuted.withValues(alpha: 0.5)
                  : t.text,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: dot ?? Colors.transparent, shape: BoxShape.circle),
        ),
      ],
    );
  }
}
