import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoo/main.dart';

void main() {
  testWidgets('App boots and shows its name', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: YooApp()));
    expect(find.text('Yoo'), findsOneWidget);
  });
}
