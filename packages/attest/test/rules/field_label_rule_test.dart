import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';
import '../support/matchers.dart';

void main() {
  const rule = FieldLabelRule();

  test('flags a text field with no label', () {
    final snapshot = snap(node(flags: {isTextField}));
    expect(
      evaluate(rule, snapshot),
      hasFinding('attest/field-label', wcag: '1.3.1'),
    );
  });

  test('flags a checkbox with no label', () {
    final snapshot = snap(node(flags: {hasCheckedState}, actions: {tap}));
    expect(evaluate(rule, snapshot), hasFinding('attest/field-label'));
  });

  test('flags a switch with no label', () {
    final snapshot = snap(node(flags: {hasToggledState}, actions: {tap}));
    expect(evaluate(rule, snapshot), hasFinding('attest/field-label'));
  });

  test('accepts a labelled field', () {
    final snapshot = snap(node(flags: {isTextField}, label: 'Email'));
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('a hint does not count as a label', () {
    final snapshot = snap(node(flags: {isTextField}, hint: 'Email'));
    expect(evaluate(rule, snapshot), hasFinding('attest/field-label'));
  });
}
