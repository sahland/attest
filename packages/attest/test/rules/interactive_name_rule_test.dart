import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';
import '../support/matchers.dart';

void main() {
  const rule = InteractiveNameRule();

  test('flags an unnamed button', () {
    final snapshot = snap(node(flags: {isButton}, actions: {tap}));
    expect(
      evaluate(rule, snapshot),
      hasFinding('attest/interactive-name', wcag: '4.1.2'),
    );
  });

  test('flags a tappable node with no name', () {
    final snapshot = snap(node(actions: {tap}));
    expect(evaluate(rule, snapshot), hasFinding('attest/interactive-name'));
  });

  test('attaches a ready-to-paste code example to the finding', () {
    final snapshot = snap(node(flags: {isButton}, actions: {tap}));
    final finding = evaluate(rule, snapshot).single;
    expect(finding.codeExample, isNotNull);
    expect(finding.codeExample, contains('// Before'));
    expect(finding.codeExample, contains('// After'));
    expect(finding.codeExample, contains('tooltip:'));
  });

  test('accepts a named button', () {
    final snapshot =
        snap(node(flags: {isButton}, actions: {tap}, label: 'Pay'));
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('accepts a button named by a tooltip', () {
    final snapshot = snap(
      node(flags: {isButton}, actions: {tap}, tooltip: 'Pay'),
    );
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('accepts a button whose child text supplies the name', () {
    final snapshot = snap(
      node(
        flags: {isButton},
        actions: {tap},
        children: [node(label: 'Pay')],
      ),
    );
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('does not flag a text field (left to the field-label rule)', () {
    final snapshot = snap(node(flags: {isTextField}, actions: {tap}));
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('does not flag a non-interactive node', () {
    final snapshot = snap(node());
    expect(evaluate(rule, snapshot), isEmpty);
  });
}
