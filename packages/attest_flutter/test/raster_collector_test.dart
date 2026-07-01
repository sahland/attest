import 'package:attest_flutter/attest_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _screen(Color textColor) => MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Account balance',
            style: TextStyle(color: textColor, fontSize: 16),
          ),
        ),
      ),
    );

void main() {
  testWidgets('measures the contrast of a known colour pair', (tester) async {
    await tester.pumpWidget(_screen(Colors.black));

    final samples = await const RasterCollector().collect(tester);
    final sample = samples.firstWhere((s) => s.label == 'Account balance');

    // Black on white is the maximum WCAG ratio, 21:1.
    expect(sample.contrastRatio, closeTo(21, 1.5));
  });

  testWidgets('flags low-contrast text through the full audit', (tester) async {
    await tester.pumpWidget(_screen(const Color(0xFFBBBBBB)));

    final report = await tester.auditAccessibility(textScales: const [1.0]);

    expect(
      report.findings.map((f) => f.ruleId),
      contains('attest/contrast'),
    );
  });

  testWidgets('does not flag high-contrast text', (tester) async {
    await tester.pumpWidget(_screen(Colors.black));

    final report = await tester.auditAccessibility(textScales: const [1.0]);

    expect(
      report.findings.where((f) => f.ruleId == 'attest/contrast'),
      isEmpty,
    );
  });
}
