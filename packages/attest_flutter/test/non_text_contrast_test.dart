import 'package:attest_flutter/attest_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _iconScreen(Color color, double size) => MaterialApp(
  home: Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Icon(Icons.settings, color: color, size: size),
    ),
  ),
);

void main() {
  testWidgets('an icon glyph is collected as a non-text sample', (
    tester,
  ) async {
    await tester.pumpWidget(_iconScreen(const Color(0xFF808080), 24));

    final samples = await const RasterCollector().collect(tester);
    expect(samples, isNotEmpty);
    expect(samples.every((s) => s.isNonText), isTrue);
  });

  testWidgets(
    'a small icon at ~3.95:1 is no longer a false text-contrast error',
    (tester) async {
      // #808080 on white is ~3.95:1: it fails the 4.5:1 text minimum but meets
      // the 3:1 non-text minimum, so a small icon must produce no finding.
      await tester.pumpWidget(_iconScreen(const Color(0xFF808080), 18));

      final report = await tester.auditAccessibility(textScales: const [1.0]);

      expect(
        report.findings.where(
          (f) =>
              f.ruleId == 'attest/contrast' ||
              f.ruleId == 'attest/non-text-contrast',
        ),
        isEmpty,
      );
    },
  );

  testWidgets('a genuinely low-contrast icon is flagged under 1.4.11', (
    tester,
  ) async {
    // #CCCCCC on white is ~1.6:1: below the 3:1 non-text minimum.
    await tester.pumpWidget(_iconScreen(const Color(0xFFCCCCCC), 24));

    final report = await tester.auditAccessibility(textScales: const [1.0]);
    final findings = report.findings
        .where((f) => f.ruleId == 'attest/non-text-contrast')
        .toList();

    expect(findings, isNotEmpty);
    expect(findings.first.criterion.wcag, '1.4.11');
    // It must not be double-reported as a text-contrast failure.
    expect(
      report.findings.where((f) => f.ruleId == 'attest/contrast'),
      isEmpty,
    );
  });
}
