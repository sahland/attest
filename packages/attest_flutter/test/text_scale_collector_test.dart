import 'package:attest_flutter/attest_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _fragile({required bool flexible}) {
  const label = Text('Settings overview panel');
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 200,
          child: Row(
            children: [
              if (flexible) const Flexible(child: label) else label,
              const Icon(Icons.info),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('detects overflow at an enlarged text scale', (tester) async {
    await tester.pumpWidget(_fragile(flexible: false));

    final observations = await const TextScaleCollector().collect(
      tester,
      const [1.0, 2.0],
    );

    final atTwo = observations.firstWhere((o) => o.textScale == 2.0);
    expect(atTwo.overflowed, isTrue);
  });

  testWidgets('a flexible layout does not overflow', (tester) async {
    await tester.pumpWidget(_fragile(flexible: true));

    final observations = await const TextScaleCollector().collect(
      tester,
      const [1.0, 2.0],
    );

    final atTwo = observations.firstWhere((o) => o.textScale == 2.0);
    expect(atTwo.overflowed, isFalse);
  });
}
