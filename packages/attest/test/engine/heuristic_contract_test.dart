import 'package:attest/attest.dart';
import 'package:attest/corpus.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';

/// The contract every heuristic rule must honour (see
/// `context/Stage2/15_PHASE1_PLAN.md`, P1.4): a declared precision bar, a
/// visible `heuristic` tag on every finding, and one-line suppression via
/// [RuleConfig.disabledRules].
void main() {
  final engine = RuleEngine.standard();
  final heuristicIds = {
    for (final rule in engine.rules)
      if (rule.confidence == Confidence.heuristic) rule.id,
  };

  // A snapshot that fires each heuristic under the default pack and config.
  final firingSnapshots = <String, SemanticsSnapshot>{
    'attest/ambiguous-name': snap(
      node(
        children: [
          node(label: 'Delete', flags: {isButton}, actions: {tap}),
          node(label: 'Delete', flags: {isButton}, actions: {tap}),
        ],
      ),
    ),
    'attest/heading-structure': snap(
      node(
        label: 'Welcome',
        textStyle: const TextStyleData(fontSize: 28),
      ),
    ),
    'attest/focus-order': snap(
      node(
        children: [
          node(label: 'lower', bounds: rect(0, 200, 100, 48)),
          node(label: 'upper', bounds: rect(0, 0, 100, 48)),
        ],
      ),
    ),
    'attest/state-exposed': snap(
      node(
        children: [
          node(label: 'Day', actions: {tap}),
          node(label: 'Week', actions: {tap}),
        ],
      ),
    ),
    'attest/generic-link-text': snap(
      node(label: 'Read more', flags: {isLink}, actions: {tap}),
    ),
  };

  AuditReport run(
    SemanticsSnapshot snapshot, {
    Set<String> disabled = const {},
  }) {
    return engine.run(
      snapshot,
      meta: AuditMeta(
        screenName: 'heuristic-contract',
        standard: Standard.en301549_v3_2_1.name,
        toolVersion: 'test',
        timestamp: DateTime.utc(2026),
      ),
      config: RuleConfig(disabledRules: disabled),
    );
  }

  test('every heuristic rule declares a precision bar (and nothing else does)',
      () {
    expect(declaredHeuristicPrecision.keys.toSet(), heuristicIds);
  });

  test('each firing snapshot covers exactly the declared heuristics', () {
    expect(firingSnapshots.keys.toSet(), heuristicIds);
  });

  for (final id in firingSnapshots.keys) {
    final snapshot = firingSnapshots[id]!;

    test('$id fires and tags every finding as heuristic', () {
      final findings =
          run(snapshot).findings.where((f) => f.ruleId == id).toList();
      expect(findings, isNotEmpty, reason: 'fixture must trip the rule');
      for (final finding in findings) {
        expect(finding.confidence, Confidence.heuristic, reason: id);
      }
    });

    test('$id is suppressible in one line via disabledRules', () {
      final findings =
          run(snapshot, disabled: {id}).findings.where((f) => f.ruleId == id);
      expect(findings, isEmpty, reason: '$id must be mutable in one line');
    });
  }
}
