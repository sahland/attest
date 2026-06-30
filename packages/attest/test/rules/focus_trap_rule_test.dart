import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';
import '../support/matchers.dart';

void main() {
  const rule = FocusTrapRule();

  test('flags a tappable but hidden element', () {
    final snapshot = snap(
      node(flags: {isButton, isHidden}, actions: {tap}, label: 'Buy'),
    );
    expect(
      evaluate(rule, snapshot),
      hasFinding('attest/focus-trap', wcag: '2.1.1'),
    );
  });

  test('accepts a visible interactive element', () {
    final snapshot =
        snap(node(flags: {isButton}, actions: {tap}, label: 'Buy'));
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('accepts a hidden, non-interactive element', () {
    final snapshot = snap(node(flags: {isHidden}, label: 'Decorative'));
    expect(evaluate(rule, snapshot), isEmpty);
  });
}
