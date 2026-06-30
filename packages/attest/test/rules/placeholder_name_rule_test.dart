import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';
import '../support/matchers.dart';

void main() {
  const rule = PlaceholderNameRule();

  test('flags a button named with a placeholder token', () {
    final snapshot =
        snap(node(flags: {isButton}, actions: {tap}, label: 'button'));
    expect(
      evaluate(rule, snapshot),
      hasFinding('attest/placeholder-name', wcag: '2.4.6'),
    );
  });

  test('matching is case-insensitive', () {
    final snapshot = snap(node(flags: {isImage}, label: 'Image'));
    expect(evaluate(rule, snapshot), hasFinding('attest/placeholder-name'));
  });

  test('accepts a meaningful name', () {
    final snapshot =
        snap(node(flags: {isButton}, actions: {tap}, label: 'Pay'));
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('does not flag a plain text node, only nameable elements', () {
    final snapshot = snap(node(label: 'text'));
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('honours a custom denylist', () {
    final snapshot =
        snap(node(flags: {isButton}, actions: {tap}, label: 'foo'));
    expect(
      evaluate(
        rule,
        snapshot,
        config: const RuleConfig(placeholderDenylist: {'foo'}),
      ),
      hasFinding('attest/placeholder-name'),
    );
  });
}
