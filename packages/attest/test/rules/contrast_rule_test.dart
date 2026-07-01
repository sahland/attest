import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';
import '../support/matchers.dart';

void main() {
  const rule = ContrastRule();

  ContrastSample sample({
    required double fg,
    required double bg,
    double? fontSize,
    bool isBold = false,
    bool isDisabled = false,
  }) =>
      ContrastSample(
        label: 'Total',
        foregroundLuminance: fg,
        backgroundLuminance: bg,
        bounds: RectData.zero,
        fontSize: fontSize,
        isBold: isBold,
        isDisabled: isDisabled,
      );

  List<Finding> run(ContrastSample s) =>
      evaluate(rule, snap(node(label: 'screen'), contrastSamples: [s]));

  test('flags clearly insufficient contrast as an error', () {
    // ratio = (0.30 + 0.05) / (0.05 + 0.05) = 3.5.
    final findings = run(sample(fg: 0.30, bg: 0.05));
    expect(findings, hasFinding('attest/contrast', wcag: '1.4.3'));
    expect(findings.single.severity, Severity.error);
  });

  test('accepts sufficient contrast', () {
    // ratio = (1 + 0.05) / (0 + 0.05) = 21.
    expect(run(sample(fg: 0, bg: 1)), isEmpty);
  });

  test('large text uses the relaxed 3:1 threshold', () {
    // ratio 3.5 fails for normal text but passes for large text.
    expect(run(sample(fg: 0.30, bg: 0.05)), isNotEmpty);
    expect(run(sample(fg: 0.30, bg: 0.05, fontSize: 24)), isEmpty);
  });

  test('downgrades a borderline ratio to a warning', () {
    // ratio = (0.39 + 0.05) / (0.05 + 0.05) = 4.4, just under 4.5.
    final findings = run(sample(fg: 0.39, bg: 0.05));
    expect(findings.single.severity, Severity.warning);
  });

  test('exempts disabled controls', () {
    expect(run(sample(fg: 0, bg: 0, isDisabled: true)), isEmpty);
  });

  test('yields nothing without samples (pure-Dart snapshot)', () {
    expect(evaluate(rule, snap(node(label: 'screen'))), isEmpty);
  });
}
