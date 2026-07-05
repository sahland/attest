import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';
import '../support/matchers.dart';

void main() {
  const rule = GenericLinkTextRule();

  List<Finding> run(
    String label, {
    Set<SemanticsFlagData> flags = const {isLink},
  }) =>
      evaluate(rule, snap(node(label: label, flags: flags, actions: {tap})));

  test('flags a "Read more" link as a heuristic warning', () {
    final findings = run('Read more');
    expect(findings, hasFinding('attest/generic-link-text', wcag: '2.4.4'));
    expect(findings.single.confidence, Confidence.heuristic);
    expect(findings.single.severity, Severity.warning);
  });

  test('flags "click here" case-insensitively', () {
    expect(run('Click Here'), isNotEmpty);
  });

  test('accepts a descriptive link', () {
    expect(run('Read the 2026 annual report'), isEmpty);
  });

  test('only targets links, not buttons', () {
    expect(run('Read more', flags: {isButton}), isEmpty);
  });

  test('ignores an unnamed link (left to interactive-name)', () {
    expect(
      evaluate(rule, snap(node(flags: {isLink}, actions: {tap}))),
      isEmpty,
    );
  });
}
