import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';
import '../support/matchers.dart';

void main() {
  const rule = FocusOrderRule();

  test('flags an upward jump in traversal order', () {
    final snapshot = snap(
      node(
        children: [
          node(label: 'Reached first', bounds: rect(0, 200, 100, 40)),
          node(label: 'Reached second', bounds: rect(0, 0, 100, 40)),
        ],
      ),
    );
    expect(
      evaluate(rule, snapshot),
      hasFinding('attest/focus-order', wcag: '2.4.3'),
    );
  });

  test('accepts top-to-bottom traversal', () {
    final snapshot = snap(
      node(
        children: [
          node(label: 'Top', bounds: rect(0, 0, 100, 40)),
          node(label: 'Bottom', bounds: rect(0, 200, 100, 40)),
        ],
      ),
    );
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('ignores children with unknown bounds', () {
    final snapshot = snap(
      node(
        children: [
          node(label: 'a'),
          node(label: 'b'),
        ],
      ),
    );
    expect(evaluate(rule, snapshot), isEmpty);
  });
}
