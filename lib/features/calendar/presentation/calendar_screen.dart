import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Calendar tab: monthly calendar and monthly goals (implemented in phase 6).
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: Text(context.l10n.navCalendar))),
    );
  }
}
