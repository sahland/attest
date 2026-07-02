import 'package:attest/attest.dart';
import 'package:attest/corpus.dart';
import 'package:test/test.dart';

import 'all_cases.dart';

/// Foundation checks for the corpus (P1.1): the sample cases load, are
/// well-formed, and — as an end-to-end smoke test of the identifier plumbing —
/// audit exactly as they are labelled.
void main() {
  test('every case has a unique id', () {
    final ids = corpusCases.map((c) => c.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('ruleUnderTest is set for every category except realWorld', () {
    for (final c in corpusCases) {
      if (c.category == CorpusCategory.realWorld) {
        expect(c.ruleUnderTest, isNull, reason: '${c.id} is realWorld');
      } else {
        expect(
          c.ruleUnderTest,
          isNotNull,
          reason: '${c.id} must isolate a rule',
        );
      }
    }
  });

  test('expected findings anchor on a non-empty identifier', () {
    for (final c in corpusCases) {
      for (final e in c.expected) {
        expect(e.identifier, isNotEmpty, reason: c.id);
        if (c.isIsolated) {
          expect(e.ruleId, c.ruleUnderTest, reason: c.id);
        }
      }
    }
  });

  group('sample cases audit as labelled', () {
    late Map<String, CorpusCase> byId;
    setUp(() => byId = {for (final c in corpusCases) c.id: c});

    Future<List<Finding>> auditOf(CorpusCase c) async {
      final snapshot = await Future<SemanticsSnapshot>.value(c.build());
      final report = RuleEngine.standard().run(
        snapshot,
        meta: AuditMeta(
          screenName: c.id,
          standard: c.standard.name,
          toolVersion: 'test',
          timestamp: DateTime.utc(2026),
        ),
        config: RuleConfig(standard: c.standard),
      );
      return report.findings;
    }

    test('positive case fires and anchors to the offender identifier',
        () async {
      final c = byId['interactive_name/unnamed_button']!;
      final firings =
          (await auditOf(c)).where((f) => f.ruleId == c.ruleUnderTest).toList();
      expect(firings, isNotEmpty);
      expect(firings.single.identifier, 'offender.pay-button');
    });

    test('clean case stays silent for its rule', () async {
      final c = byId['interactive_name/labeled_button']!;
      expect(
        (await auditOf(c)).where((f) => f.ruleId == c.ruleUnderTest),
        isEmpty,
      );
    });

    test('adversarial case stays silent for its rule', () async {
      final c = byId['interactive_name/named_by_child_text']!;
      expect(
        (await auditOf(c)).where((f) => f.ruleId == c.ruleUnderTest),
        isEmpty,
      );
    });
  });
}
