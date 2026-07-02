import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';
import '../support/matchers.dart';

void main() {
  const rule = NonTextContrastRule();

  ContrastSample icon({
    required double fg,
    required double bg,
    double? fontSize,
    bool isDisabled = false,
    bool isNonText = true,
  }) =>
      ContrastSample(
        label: 'icon',
        foregroundLuminance: fg,
        backgroundLuminance: bg,
        bounds: RectData.zero,
        fontSize: fontSize,
        isDisabled: isDisabled,
        isNonText: isNonText,
      );

  List<Finding> run(ContrastSample s) =>
      evaluate(rule, snap(node(label: 'screen'), contrastSamples: [s]));

  test('flags an icon below 3:1 as an error', () {
    // ratio = (0.05 + 0.05) / (0 + 0.05) = 2.0.
    final findings = run(icon(fg: 0, bg: 0.05));
    expect(findings, hasFinding('attest/non-text-contrast', wcag: '1.4.11'));
    expect(findings.single.severity, Severity.error);
  });

  test('accepts an icon at or above 3:1', () {
    // ratio = (0.30 + 0.05) / (0.05 + 0.05) = 3.5 — fails 1.4.3 text but is a
    // valid non-text ratio; this is the false positive the rule split fixes.
    expect(run(icon(fg: 0.30, bg: 0.05)), isEmpty);
  });

  test('downgrades a borderline ratio to a warning', () {
    // ratio = (0.095 + 0.05) / (0 + 0.05) = 2.9, just under 3.0.
    expect(run(icon(fg: 0, bg: 0.095)).single.severity, Severity.warning);
  });

  test('exempts disabled controls', () {
    expect(run(icon(fg: 0, bg: 0, isDisabled: true)), isEmpty);
  });

  test('ignores text samples (left to the contrast rule)', () {
    expect(run(icon(fg: 0, bg: 0.05, isNonText: false)), isEmpty);
  });

  test('yields nothing without samples (pure-Dart snapshot)', () {
    expect(evaluate(rule, snap(node(label: 'screen'))), isEmpty);
  });
}
