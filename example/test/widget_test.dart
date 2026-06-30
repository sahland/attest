import 'package:a11y_audit_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example app builds', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('a11y_audit example'), findsWidgets);
  });
}
