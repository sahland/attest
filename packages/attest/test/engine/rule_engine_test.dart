import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';

void main() {
  final meta = AuditMeta(
    screenName: 'Test',
    standard: 'en301549_v3_2_1',
    toolVersion: '0.1.0',
    timestamp: DateTime.utc(2026),
  );

  final engine = RuleEngine.standard();

  test('reports each defect once and fails the gate', () {
    final snapshot = snap(
      node(
        children: [
          node(flags: {isButton}, actions: {tap}), // interactive-name
          node(flags: {isImage}), // image-alt
          node(flags: {isTextField}), // field-label
          node(
            flags: {isButton},
            actions: {tap},
            label: 'button',
          ), // placeholder
        ],
      ),
    );

    final report = engine.run(snapshot, meta: meta);
    final ruleIds = report.findings.map((f) => f.ruleId).toList();

    expect(ruleIds, contains('attest/interactive-name'));
    expect(ruleIds, contains('attest/image-alt'));
    expect(ruleIds, contains('attest/field-label'));
    expect(ruleIds, contains('attest/placeholder-name'));
    expect(report.passes, isFalse);
  });

  test('findings come back in a deterministic order', () {
    final snapshot = snap(
      node(
        children: [
          node(flags: {isTextField}),
          node(flags: {isButton}, actions: {tap}),
          node(flags: {isImage}),
        ],
      ),
    );

    List<String> run() =>
        engine.run(snapshot, meta: meta).findings.map((f) => f.ruleId).toList();

    expect(run(), equals(run()));
    expect(run(), equals(List<String>.from(run())..sort()));
  });

  test('a clean screen passes', () {
    final snapshot = snap(
      node(
        children: [
          node(flags: {isButton}, actions: {tap}, label: 'Pay'),
          node(flags: {isImage}, label: 'Revenue chart'),
          node(flags: {isTextField}, label: 'Email'),
        ],
      ),
    );

    final report = engine.run(snapshot, meta: meta);
    expect(report.findings, isEmpty);
    expect(report.passes, isTrue);
  });

  test('a warning-only screen passes the default error gate but still reports',
      () {
    final snapshot = snap(
      node(flags: {isButton}, actions: {tap}, label: 'button'),
    );

    final report = engine.run(snapshot, meta: meta);
    expect(report.findings, isNotEmpty);
    expect(
      report.findings.every((f) => f.severity == Severity.warning),
      isTrue,
    );
    expect(report.passes, isTrue);
  });
}
