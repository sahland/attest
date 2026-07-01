import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';

void main() {
  test('includes gates WCAG 2.2-only criteria', () {
    expect(Standard.en301549_v3_2_1.includes(Criteria.targetSize), isFalse);
    expect(Standard.wcag22.includes(Criteria.targetSize), isTrue);
    expect(Standard.en301549_v3_2_1.includes(Criteria.nameRoleValue), isTrue);
    expect(Standard.wcag22.includes(Criteria.nameRoleValue), isTrue);
  });

  test('round-trips through JSON', () {
    expect(Standard.fromJson(Standard.wcag22.toJson()), Standard.wcag22);
  });

  test('the engine runs only the selected pack', () {
    final meta = AuditMeta(
      screenName: 'Test',
      standard: 'x',
      toolVersion: '0.1.0',
      timestamp: DateTime.utc(2026),
    );
    final engine = RuleEngine.standard();
    final snapshot = snap(
      node(label: 'Tiny', actions: {tap}, bounds: rect(0, 0, 24, 24)),
    );

    // The default pack is EN 301 549 v3.2.1.
    final under21 =
        engine.run(snapshot, meta: meta).findings.map((f) => f.ruleId);
    expect(under21, isNot(contains('attest/target-size')));

    final under22 = engine
        .run(
          snapshot,
          meta: meta,
          config: const RuleConfig(standard: Standard.wcag22),
        )
        .findings
        .map((f) => f.ruleId);
    expect(under22, contains('attest/target-size'));
  });
}
