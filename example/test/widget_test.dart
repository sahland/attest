import 'package:attest_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example app builds', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('attest example'), findsWidgets);
  });
}
