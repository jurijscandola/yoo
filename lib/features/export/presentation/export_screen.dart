import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/yoo_tokens.dart';
import '../../../core/time/date_labels.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/l10n.dart';
import '../application/month_text_formatter.dart';
import 'export_providers.dart';

/// Monthly export: pick a month (up to the current one), preview the text and
/// send the .txt file to the export destination.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  /// First day of the chosen month; `null` means the current month.
  LocalDate? _month;
  bool _busy = false;

  Future<void> _export(LocalDate month, String content) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.exportFailed;
    final name = 'Yoo-${month.year}-${month.month.toString().padLeft(2, '0')}.txt';
    try {
      await ref
          .read(exportDestinationProvider)
          .deliver(fileName: name, content: content, subject: name);
    } catch (error) {
      debugPrint('Export failed: $error');
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final today = ref.watch(todayProvider);
    final month = _month ?? today.firstOfMonth;
    final isCurrent = month == today.firstOfMonth;
    final monthLabel = context.monthYear(month.year, month.month);
    final report = ref.watch(monthReportProvider((month.year, month.month))).value;
    // The file keeps the formatter's CRLF line ends; the preview shows LF.
    final content = report == null || report.isEmpty
        ? null
        : MonthTextFormatter(
            l10n: l10n,
            monthLabel: monthLabel,
            dayLabel: context.fullDate,
            exportedOn: context.fullDate(today),
          ).format(report);
    final text = content?.replaceAll('\r\n', '\n');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsExport)),
      // Keeps the end of the list above the system navigation bar
      // (edge-to-edge on Android 15+).
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(l10n.exportDescription, style: TextStyle(color: t.textMuted)),
            const SizedBox(height: 16),
            Material(
              color: t.surface,
              borderRadius: BorderRadius.circular(t.radius),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.previousMonth,
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(() => _month = month.addMonths(-1)),
                  ),
                  Expanded(
                    child: Text(
                      monthLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.nextMonth,
                    icon: const Icon(Icons.chevron_right),
                    onPressed: isCurrent ? null : () => setState(() => _month = month.addMonths(1)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radius)),
              ),
              icon: const Icon(Icons.ios_share),
              label: Text(l10n.exportButton(monthLabel)),
              onPressed: text == null || _busy ? null : () => _export(month, content!),
            ),
            const SizedBox(height: 20),
            if (report != null && text == null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(l10n.exportEmpty, style: TextStyle(color: t.textMuted)),
                ),
              ),
            if (text != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
                child: Text(
                  l10n.exportPreview,
                  style: TextStyle(color: t.textMuted, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(t.radius),
                ),
                child: SelectableText(
                  text,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    height: 1.45,
                    color: t.text,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
