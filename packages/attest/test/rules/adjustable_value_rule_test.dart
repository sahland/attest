import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';
import '../support/matchers.dart';

void main() {
  const rule = AdjustableValueRule();

  test('flags a slider with no value', () {
    final snapshot = snap(node(actions: {increase, decrease}));
    expect(
      evaluate(rule, snapshot),
      hasFinding('attest/adjustable-value', wcag: '4.1.2'),
    );
  });

  test('flags an increase-only control with no value', () {
    expect(evaluate(rule, snap(node(actions: {increase}))), isNotEmpty);
  });

  test('a label is not a value', () {
    final snapshot = snap(node(label: 'Volume', actions: {increase, decrease}));
    expect(evaluate(rule, snapshot), isNotEmpty);
  });

  test('accepts an adjustable control that exposes a value', () {
    final snapshot = snap(node(value: '50%', actions: {increase, decrease}));
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('ignores a plain button', () {
    final snapshot = snap(node(flags: {isButton}, actions: {tap}));
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('ignores a scrollable (scrolling is not adjusting a value)', () {
    final snapshot = snap(node(actions: {scrollUp, scrollDown}));
    expect(evaluate(rule, snapshot), isEmpty);
  });
}
