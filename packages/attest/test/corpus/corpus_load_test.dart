import 'package:attest/attest.dart';
import 'package:attest/corpus.dart';
import 'package:test/test.dart';

import 'all_cases.dart';

/// Structural invariants for the corpus. The actual auditing (and the
/// precision/recall gate) lives in `metrics_test.dart`; here we only check the
/// cases are well-formed so a mistake fails loudly and specifically.
void main() {
  test('every case id is unique', () {
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

  test('clean and adversarial cases carry no expected findings', () {
    for (final c in corpusCases) {
      if (c.category == CorpusCategory.clean ||
          c.category == CorpusCategory.adversarial) {
        expect(c.expected, isEmpty, reason: '${c.id} must stay silent');
      }
    }
  });

  test('positive cases expect at least one finding, each with an identifier',
      () {
    for (final c in corpusCases) {
      if (c.category != CorpusCategory.positive) continue;
      expect(c.expected, isNotEmpty, reason: '${c.id} must expect a finding');
      for (final e in c.expected) {
        expect(e.identifier, isNotEmpty, reason: c.id);
        expect(e.ruleId, c.ruleUnderTest, reason: c.id);
      }
    }
  });

  test('every expected identifier resolves to a node in the snapshot',
      () async {
    for (final c in corpusCases) {
      final snapshot = await Future<SemanticsSnapshot>.value(c.build());
      final identifiers = snapshot.allNodes
          .map((SemanticsNodeData n) => n.identifier)
          .whereType<String>()
          .toSet()
        ..addAll(
          snapshot.contrastSamples
              .map((ContrastSample s) => s.identifier)
              .whereType<String>(),
        );
      for (final e in c.expected) {
        expect(
          identifiers,
          contains(e.identifier),
          reason: '${c.id}: expected identifier "${e.identifier}" is not on '
              'any node in the built snapshot',
        );
      }
    }
  });
}
