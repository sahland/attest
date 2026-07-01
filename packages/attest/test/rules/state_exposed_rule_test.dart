import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';
import '../support/matchers.dart';

void main() {
  const rule = StateExposedRule();

  SemanticsNodeData tab(
    String label, {
    Set<SemanticsFlagData> flags = const {},
  }) =>
      node(label: label, actions: {tap}, flags: flags);

  test('flags a group of custom tappables with no state', () {
    final snapshot = snap(
      node(children: [tab('Day'), tab('Week'), tab('Month')]),
    );
    final findings = evaluate(rule, snapshot);
    expect(findings, hasFinding('attest/state-exposed', wcag: '4.1.2'));
    expect(findings, hasLength(3));
  });

  test('stays silent when a sibling already exposes state', () {
    final snapshot = snap(
      node(
        children: [
          tab('Day', flags: {isSelected}),
          tab('Week'),
          tab('Month'),
        ],
      ),
    );
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('does not flag native buttons', () {
    final snapshot = snap(
      node(
        children: [
          tab('Day', flags: {isButton}),
          tab('Week', flags: {isButton}),
          tab('Month', flags: {isButton}),
        ],
      ),
    );
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('does not flag a group smaller than three', () {
    final snapshot = snap(node(children: [tab('Day'), tab('Week')]));
    expect(evaluate(rule, snapshot), isEmpty);
  });
}
