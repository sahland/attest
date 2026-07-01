import 'package:attest_flutter/attest_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('flags an icon button with no accessible name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ),
      ),
    );

    final report = await tester.auditAccessibility(screenName: 'Defect');

    expect(report.passes, isFalse);
    expect(report, isNot(passesAccessibilityGate()));
    expect(
      report.findings.map((f) => f.ruleId),
      contains('attest/interactive-name'),
    );
  });

  testWidgets('a labelled button passes the gate', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {},
            child: const Text('Pay'),
          ),
        ),
      ),
    );

    final report = await tester.auditAccessibility(
      screenName: 'Clean',
      contrast: false,
      textScales: const [1.0],
    );

    expect(report, passesAccessibilityGate());
    expect(report, hasNoAccessibilityViolations());
  });

  testWidgets('the gate failure description is grouped and readable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ),
      ),
    );

    final report = await tester.auditAccessibility(
      screenName: 'Defect',
      contrast: false,
      textScales: const [1.0],
    );

    final mismatch = StringDescription();
    passesAccessibilityGate().describeMismatch(report, mismatch, {}, false);
    final text = mismatch.toString();

    expect(text, contains('Defect — 1 accessibility violation'));
    expect(text, contains('attest/interactive-name'));
    expect(text, contains('Fix:'));
  });
}
