import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Home tab: the activities of the selected day (implemented in phase 4).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: Text(context.l10n.navHome))),
    );
  }
}
