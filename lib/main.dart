import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Entry point of Yoo.
///
/// Bootstrapping (database, time zones, notifications) is added in later phases.
void main() {
  runApp(const ProviderScope(child: YooApp()));
}

/// Temporary root widget used until the app shell is implemented.
class YooApp extends StatelessWidget {
  const YooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Yoo',
      home: Scaffold(body: Center(child: Text('Yoo'))),
    );
  }
}
