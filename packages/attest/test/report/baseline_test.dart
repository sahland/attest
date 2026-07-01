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

  group('Baseline', () {
    test('survives a JSON round-trip', () {
      const baseline = Baseline({'aaa', 'bbb'});
      expect(Baseline.fromJson(baseline.toJson()), equals(baseline));
    });

    test('serializes fingerprints sorted', () {
      const baseline = Baseline({'ccc', 'aaa', 'bbb'});
      expect(baseline.toJson()['fingerprints'], ['aaa', 'bbb', 'ccc']);
    });
  });

  group('BaselineGate', () {
    List<Finding> findingsFor(SemanticsSnapshot snapshot) =>
        engine.run(snapshot, meta: meta).findings;

    test('detects a new finding not in the baseline', () {
      const baseline = Baseline.empty;
      final findings = findingsFor(
        snap(node(flags: {isButton}, actions: {tap})),
      );
      final result = const BaselineGate(baseline).evaluate(findings);
      expect(result.newFindings, isNotEmpty);
      expect(result.passed, isFalse);
    });

    test('passes when every finding is already accepted', () {
      final findings = findingsFor(
        snap(node(flags: {isButton}, actions: {tap})),
      );
      final baseline = Baseline.fromFindings(findings);
      final result = BaselineGate(baseline).evaluate(findings);
      expect(result.newFindings, isEmpty);
      expect(result.knownFindings, isNotEmpty);
      expect(result.passed, isTrue);
    });

    test('reports baseline fingerprints no longer produced as resolved', () {
      const baseline = Baseline({'ghost-fingerprint'});
      final result = const BaselineGate(baseline).evaluate(const []);
      expect(result.resolvedFingerprints, contains('ghost-fingerprint'));
    });

    test('stays green when only the layout shifts', () {
      final original = findingsFor(
        snap(
          node(
            flags: {isButton},
            actions: {tap},
            label: 'button',
            bounds: rect(0, 0, 48, 48),
          ),
        ),
      );
      final baseline = Baseline.fromFindings(original);

      final shifted = findingsFor(
        snap(
          node(
            flags: {isButton},
            actions: {tap},
            label: 'button',
            bounds: rect(300, 700, 48, 48),
          ),
        ),
      );
      expect(BaselineGate(baseline).evaluate(shifted).passed, isTrue);
    });

    test('flags a genuine regression as new', () {
      final baseline = Baseline.fromFindings(
        findingsFor(
          snap(node(flags: {isButton}, actions: {tap}, label: 'button')),
        ),
      );
      final regressed = findingsFor(snap(node(flags: {isImage})));
      expect(
        BaselineGate(baseline).evaluate(regressed).newFindings,
        isNotEmpty,
      );
    });
  });
}
