import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';
import '../support/matchers.dart';

void main() {
  const rule = AmbiguousNameRule();

  test('flags two interactive elements sharing a name', () {
    final snapshot = snap(
      node(
        children: [
          node(flags: {isButton}, actions: {tap}, label: 'Delete'),
          node(flags: {isButton}, actions: {tap}, label: 'Delete'),
        ],
      ),
    );
    final findings = evaluate(rule, snapshot);
    expect(findings, hasFinding('attest/ambiguous-name', wcag: '2.4.6'));
    expect(findings, hasLength(2));
  });

  test('matching is case-insensitive', () {
    final snapshot = snap(
      node(
        children: [
          node(flags: {isButton}, actions: {tap}, label: 'More'),
          node(flags: {isButton}, actions: {tap}, label: 'more'),
        ],
      ),
    );
    expect(evaluate(rule, snapshot), hasLength(2));
  });

  test('accepts distinct names', () {
    final snapshot = snap(
      node(
        children: [
          node(flags: {isButton}, actions: {tap}, label: 'Delete photo'),
          node(flags: {isButton}, actions: {tap}, label: 'Delete account'),
        ],
      ),
    );
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('ignores empty names and lone controls', () {
    final snapshot = snap(
      node(
        children: [
          node(flags: {isButton}, actions: {tap}),
          node(flags: {isButton}, actions: {tap}, label: 'Save'),
        ],
      ),
    );
    expect(evaluate(rule, snapshot), isEmpty);
  });
}
