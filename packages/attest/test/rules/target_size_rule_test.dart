import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';
import '../support/matchers.dart';

void main() {
  const rule = TargetSizeRule();

  test('flags a tappable target below the platform minimum', () {
    final snapshot = snap(node(actions: {tap}, bounds: rect(0, 0, 24, 24)));
    expect(
      evaluate(rule, snapshot),
      hasFinding('attest/target-size', wcag: '2.5.8'),
    );
  });

  test('accepts a target at the platform minimum', () {
    final snapshot = snap(node(actions: {tap}, bounds: rect(0, 0, 48, 48)));
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('honours the strict WCAG minimum mode', () {
    final small = snap(node(actions: {tap}, bounds: rect(0, 0, 24, 24)));
    expect(
      evaluate(
        rule,
        small,
        config: const RuleConfig(targetSizeMode: TargetSizeMode.wcagMinimum),
      ),
      isEmpty,
    );

    final tiny = snap(node(actions: {tap}, bounds: rect(0, 0, 20, 20)));
    expect(
      evaluate(
        rule,
        tiny,
        config: const RuleConfig(targetSizeMode: TargetSizeMode.wcagMinimum),
      ),
      hasFinding('attest/target-size'),
    );
  });

  test('exempts inline links', () {
    final snapshot = snap(
      node(flags: {isLink}, actions: {tap}, bounds: rect(0, 0, 12, 12)),
    );
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('exempts hidden nodes', () {
    final snapshot = snap(
      node(flags: {isHidden}, actions: {tap}, bounds: rect(0, 0, 12, 12)),
    );
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('ignores nodes with unknown (zero) bounds', () {
    final snapshot = snap(node(actions: {tap}, bounds: rect(0, 0, 0, 0)));
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('flags by size regardless of reading direction', () {
    final snapshot = snap(
      node(
        actions: {tap},
        bounds: rect(0, 0, 24, 24),
        textDirection: TextDirectionData.rtl,
      ),
    );
    expect(evaluate(rule, snapshot), hasFinding('attest/target-size'));
  });
}
