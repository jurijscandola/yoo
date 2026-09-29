import 'package:flutter/material.dart';

import '../../../../core/theme/yoo_tokens.dart';
import '../../../../core/time/date_labels.dart';
import '../../../../core/time/local_date.dart';

/// The rectangle at the top of Home showing the selected day. Tapping it
/// opens the daily summary; it is a [Hero] shared with the summary header.
class DayHeader extends StatelessWidget {
  const DayHeader({
    super.key,
    required this.date,
    required this.today,
    this.onTap,
    this.onBackToToday,
  });

  final LocalDate date;
  final LocalDate today;
  final VoidCallback? onTap;

  /// Shown as a "Today" pill when [date] is another day.
  final VoidCallback? onBackToToday;

  /// Hero tag shared with the daily summary.
  static String heroTag(LocalDate date) => 'day-header-$date';

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final relative = context.relativeDayName(date, today);
    final isToday = date == today;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Hero(
        tag: heroTag(date),
        child: Material(
          color: t.surface,
          borderRadius: BorderRadius.circular(t.radius + 4),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          relative ?? context.weekdayName(date),
                          style: TextStyle(
                            color: isToday ? t.accent : t.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          relative == null ? context.dayMonth(date) : context.fullDate(date),
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  if (!isToday && onBackToToday != null)
                    ActionChip(
                      label: Text(context.relativeDayName(today, today)!),
                      avatar: Icon(
                        today.isAfter(date) ? Icons.arrow_forward : Icons.arrow_back,
                        size: 16,
                      ),
                      onPressed: onBackToToday,
                    ),
                  Icon(Icons.chevron_right, color: t.textMuted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
