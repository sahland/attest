// Concise builders for corpus cases. A rule's case file imports only this: it
// re-exports the public corpus API and the fixture primitives (`node`, `snap`,
// the flag/action aliases) so cases read like the trees they describe.

import 'package:attest/attest.dart';
import 'package:attest/corpus.dart';

export 'package:attest/attest.dart';
export 'package:attest/corpus.dart';

export '../support/fixtures.dart';

/// Shorthand for an [ExpectedFinding].
ExpectedFinding ef(String rule, String wcag, String identifier) =>
    ExpectedFinding(ruleId: rule, wcag: wcag, identifier: identifier);

/// A positive case: [snapshot] contains the labelled violation(s) of [rule]
/// listed in [expected] and nothing else the rule should fire on.
CorpusCase positive(
  String id,
  String rule,
  SemanticsSnapshot snapshot,
  List<ExpectedFinding> expected, {
  Standard standard = Standard.en301549_v3_2_1,
}) =>
    CorpusCase(
      id: id,
      category: CorpusCategory.positive,
      standard: standard,
      ruleUnderTest: rule,
      build: () => snapshot,
      expected: expected,
    );

/// A clean case: correct for [rule]; it must stay silent.
CorpusCase clean(
  String id,
  String rule,
  SemanticsSnapshot snapshot, {
  Standard standard = Standard.en301549_v3_2_1,
}) =>
    CorpusCase(
      id: id,
      category: CorpusCategory.clean,
      standard: standard,
      ruleUnderTest: rule,
      build: () => snapshot,
    );

/// An adversarial case: a known false-positive trap for [rule]; it must stay
/// silent even though something about the input looks like a violation.
CorpusCase adversarial(
  String id,
  String rule,
  SemanticsSnapshot snapshot, {
  Standard standard = Standard.en301549_v3_2_1,
}) =>
    CorpusCase(
      id: id,
      category: CorpusCategory.adversarial,
      standard: standard,
      ruleUnderTest: rule,
      build: () => snapshot,
    );

/// A real-world composite case: every rule runs and [expected] labels every
/// finding across all of them.
CorpusCase realWorld(
  String id,
  SemanticsSnapshot snapshot,
  List<ExpectedFinding> expected, {
  Standard standard = Standard.en301549_v3_2_1,
}) =>
    CorpusCase(
      id: id,
      category: CorpusCategory.realWorld,
      standard: standard,
      build: () => snapshot,
      expected: expected,
    );
