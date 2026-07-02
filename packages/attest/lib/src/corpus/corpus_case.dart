import 'dart:async';

import 'package:meta/meta.dart';

import '../model/semantics_snapshot.dart';
import '../model/standard.dart';

/// What role a [CorpusCase] plays in measuring correctness.
///
/// The category decides how the metrics harness scores the case (see the
/// precision/recall harness): [positive] cases must be *caught*, while [clean]
/// and [adversarial] cases must stay *silent*.
@experimental
enum CorpusCategory {
  /// A screen containing exactly one known violation of the rule under test.
  /// The signal is isolated so a miss is unambiguous.
  positive,

  /// A correct screen that must produce zero findings for the rule under test.
  /// Guards against false positives and is as important as a positive case.
  clean,

  /// A known false-positive trap for the rule under test (text over a gradient,
  /// a disabled control, a decorative-but-excluded image, an RTL layout). The
  /// rule must stay silent; any finding is a false positive.
  adversarial,

  /// A composite, realistic screen audited with every rule enabled and labelled
  /// across all of them. Surfaces the messy cases synthetic fixtures miss.
  realWorld;

  /// Parses a [CorpusCategory] from its [name].
  static CorpusCategory fromJson(String json) => CorpusCategory.values.byName(
        json,
      );

  /// The JSON representation of this category (its [name]).
  String toJson() => name;
}

/// A single accessibility violation the corpus expects a case to produce.
///
/// An expectation is anchored to a semantics [identifier] rather than to a
/// source location or a fingerprint: the fixture tags the intended-offending
/// node with `Semantics(identifier: ...)` (or sets it directly in a pure-Dart
/// fixture), and the harness matches an actual finding to this expectation when
/// the rule, WCAG criterion and resolved identifier all agree.
@experimental
@immutable
class ExpectedFinding {
  /// Creates an [ExpectedFinding].
  const ExpectedFinding({
    required this.ruleId,
    required this.wcag,
    required this.identifier,
  });

  /// The id of the rule expected to fire, e.g. `attest/interactive-name`.
  final String ruleId;

  /// The WCAG success-criterion number the finding must cite, e.g. `4.1.2`.
  final String wcag;

  /// The semantics identifier of the node the finding must resolve to.
  final String identifier;

  /// Parses an [ExpectedFinding] from [json].
  factory ExpectedFinding.fromJson(Map<String, dynamic> json) =>
      ExpectedFinding(
        ruleId: json['ruleId'] as String,
        wcag: json['wcag'] as String,
        identifier: json['identifier'] as String,
      );

  /// The JSON representation of this expectation.
  Map<String, dynamic> toJson() => {
        'ruleId': ruleId,
        'wcag': wcag,
        'identifier': identifier,
      };

  @override
  bool operator ==(Object other) =>
      other is ExpectedFinding &&
      other.ruleId == ruleId &&
      other.wcag == wcag &&
      other.identifier == identifier;

  @override
  int get hashCode => Object.hash(ruleId, wcag, identifier);

  @override
  String toString() =>
      'ExpectedFinding($ruleId, wcag: $wcag, identifier: $identifier)';
}

/// One labelled case in the validation corpus: an input plus its ground truth.
///
/// The input is produced lazily by [build] — a pure-Dart [SemanticsSnapshot]
/// for a synthetic fixture, or one built from a pumped widget for a real-world
/// case. The ground truth is [expected], the set of findings a human confirmed
/// the input should produce.
///
/// For every category except [CorpusCategory.realWorld] the case isolates a
/// single [ruleUnderTest]: the harness scores only findings from that rule, so
/// unrelated rules cannot pollute the measurement. A `realWorld` case leaves
/// [ruleUnderTest] null, enables all rules, and must be labelled across every
/// one of them.
@experimental
@immutable
class CorpusCase {
  /// Creates a [CorpusCase].
  ///
  /// [ruleUnderTest] must be set for [CorpusCategory.positive],
  /// [CorpusCategory.clean] and [CorpusCategory.adversarial] cases, and left
  /// null for [CorpusCategory.realWorld].
  const CorpusCase({
    required this.id,
    required this.category,
    required this.standard,
    required this.build,
    this.expected = const [],
    this.ruleUnderTest,
  });

  /// A stable, unique id for this case, e.g. `interactive_name/unnamed_button`.
  final String id;

  /// What role this case plays in the metrics (see [CorpusCategory]).
  final CorpusCategory category;

  /// The standard pack to audit this case under. WCAG 2.2-only criteria only
  /// fire under [Standard.wcag22], so a case for such a rule must select it.
  final Standard standard;

  /// Builds the input to audit. Called once per harness run.
  final FutureOr<SemanticsSnapshot> Function() build;

  /// The findings a human confirmed this case should produce. Empty for clean
  /// and adversarial cases, which must stay silent.
  final List<ExpectedFinding> expected;

  /// The single rule this case isolates, or null for a [CorpusCategory.realWorld]
  /// case that runs every rule.
  final String? ruleUnderTest;

  /// Whether this case isolates one [ruleUnderTest] (everything but realWorld).
  bool get isIsolated => category != CorpusCategory.realWorld;

  @override
  String toString() => 'CorpusCase($id, ${category.name}, '
      'expected: ${expected.length})';
}
