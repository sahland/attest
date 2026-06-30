import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';
import '../support/matchers.dart';

void main() {
  const rule = TextOverflowRule();

  test('flags a captured overflow', () {
    final snapshot = snap(
      node(label: 'screen'),
      textScaleObservations: const [
        TextScaleObservation(textScale: 2, overflowed: true),
      ],
    );
    expect(
      evaluate(rule, snapshot),
      hasFinding('attest/text-overflow', wcag: '1.4.4'),
    );
  });

  test('accepts observations with no overflow', () {
    final snapshot = snap(
      node(label: 'screen'),
      textScaleObservations: const [
        TextScaleObservation(textScale: 2, overflowed: false),
      ],
    );
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('yields nothing without observations (pure-Dart snapshot)', () {
    expect(evaluate(rule, snap(node(label: 'screen'))), isEmpty);
  });

  test('reports a single finding when one node overflows at several scales',
      () {
    final snapshot = snap(
      node(label: 'screen'),
      textScaleObservations: const [
        TextScaleObservation(textScale: 1.3, overflowed: true),
        TextScaleObservation(textScale: 2, overflowed: true),
      ],
    );
    expect(evaluate(rule, snapshot), hasLength(1));
  });
}
