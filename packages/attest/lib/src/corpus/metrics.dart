import 'dart:async';

import 'package:collection/collection.dart';

import '../engine/rule_config.dart';
import '../engine/rule_engine.dart';
import '../model/audit_meta.dart';
import '../model/confidence.dart';
import '../model/finding.dart';
import '../model/semantics_snapshot.dart';
import '../model/standard.dart';
import 'corpus_case.dart';

/// Audits a built snapshot under a standard pack and returns its findings.
///
/// The default wraps [RuleEngine.standard]; tests inject a canned auditor so the
/// harness math can be verified against hand-computed metrics.
typedef Auditor = FutureOr<List<Finding>> Function(
  SemanticsSnapshot snapshot,
  Standard standard,
);

/// The declared precision bar for every bundled heuristic rule.
///
/// Deterministic rules are held to precision 1.0 on the corpus; heuristics are
/// held to the threshold declared here instead, and the metrics gate fails when
/// a rule measures below its bar. Declaring the number makes the quality
/// promise explicit and reviewable: lowering a bar is a visible, changelogged
/// decision, never a silent drift. A heuristic that cannot sustain a reasonable
/// bar is default-disabled rather than shipped noisy.
///
/// Current measured precision on the corpus is 1.0 for all four; the bar is set
/// at 0.9 to leave room for future, genuinely hard corpus cases without letting
/// real noise through.
const Map<String, double> declaredHeuristicPrecision = {
  'attest/ambiguous-name': 0.9,
  'attest/heading-structure': 0.9,
  'attest/focus-order': 0.9,
  'attest/state-exposed': 0.9,
};

/// Runs the validation corpus and computes per-rule precision, recall and
/// false-positive rate — the measured correctness that the 1.0 bar rests on.
///
/// See `context/Stage2/10_QUALITY_AND_CORRECTNESS.md`: trust is the product, and
/// it is a measured quantity, not a claim.
class MetricsHarness {
  /// Creates a harness.
  ///
  /// [auditor] audits each case (defaults to the standard engine).
  /// [confidenceByRule] classifies each rule as deterministic or heuristic for
  /// the gate; it defaults to the confidences the standard engine's rules
  /// declare.
  MetricsHarness({
    Auditor? auditor,
    Map<String, Confidence>? confidenceByRule,
  })  : _auditor = auditor ?? _engineAuditor(RuleEngine.standard()),
        confidenceByRule =
            confidenceByRule ?? _confidenceOf(RuleEngine.standard());

  final Auditor _auditor;

  /// How each rule is classified (deterministic vs heuristic), used by the gate.
  final Map<String, Confidence> confidenceByRule;

  /// Runs every case in [cases] and aggregates the metrics.
  ///
  /// Cases are processed in list order and matching is deterministic, so the
  /// result is stable across runs.
  Future<CorpusMetrics> run(List<CorpusCase> cases) async {
    final byRule = <String, RuleMetrics>{};
    final warnings = <String>[];

    RuleMetrics metricsFor(String ruleId) =>
        byRule.putIfAbsent(ruleId, () => RuleMetrics(ruleId));

    for (final testCase in cases) {
      final snapshot = await Future<SemanticsSnapshot>.value(testCase.build());
      final findings = await Future<List<Finding>>.value(
        _auditor(snapshot, testCase.standard),
      );

      // Only findings from the rule under test count for an isolated case;
      // realWorld cases score every rule.
      final inScope = testCase.isIsolated
          ? findings.where((f) => f.ruleId == testCase.ruleUnderTest).toList()
          : List<Finding>.of(findings);

      final consumed = <Finding>{};
      for (final expected in testCase.expected) {
        final match = inScope.firstWhereOrNull(
          (f) =>
              !consumed.contains(f) &&
              f.ruleId == expected.ruleId &&
              f.criterion.wcag == expected.wcag &&
              f.identifier == expected.identifier,
        );
        if (match != null) {
          metricsFor(expected.ruleId).truePositives++;
          consumed.add(match);
        } else {
          metricsFor(expected.ruleId).falseNegatives++;
          // Loud authoring signal: a same-rule/criterion finding exists but is
          // not anchored to the expected identifier (often a missing
          // `identifier:` on the fixture's offender).
          final unanchored = inScope.any(
            (f) =>
                f.ruleId == expected.ruleId &&
                f.criterion.wcag == expected.wcag &&
                f.identifier != expected.identifier,
          );
          if (unanchored) {
            warnings.add(
              '${testCase.id}: expected ${expected.ruleId} on '
              '"${expected.identifier}" but the matching finding resolved to a '
              'different identifier — check the fixture\'s identifiers.',
            );
          }
        }
      }

      // Every leftover in-scope finding is a false positive.
      for (final finding in inScope) {
        if (consumed.contains(finding)) continue;
        final metrics = metricsFor(finding.ruleId);
        metrics.falsePositives++;
        if (testCase.category == CorpusCategory.clean) {
          metrics.falsePositivesOnClean++;
        }
      }

      // Count clean cases per rule so fpRateOnClean has a denominator.
      if (testCase.category == CorpusCategory.clean &&
          testCase.ruleUnderTest != null) {
        metricsFor(testCase.ruleUnderTest!).cleanCases++;
      }
    }

    return CorpusMetrics(
      byRule: Map.unmodifiable(byRule),
      warnings: List.unmodifiable(warnings),
    );
  }

  static Auditor _engineAuditor(RuleEngine engine) {
    return (snapshot, standard) => engine
        .run(
          snapshot,
          meta: AuditMeta(
            screenName: 'corpus',
            standard: standard.name,
            toolVersion: 'corpus',
            timestamp: DateTime.utc(2000),
          ),
          config: RuleConfig(standard: standard),
        )
        .findings;
  }

  static Map<String, Confidence> _confidenceOf(RuleEngine engine) => {
        for (final rule in engine.rules) rule.id: rule.confidence,
      };
}

/// The confusion-matrix tallies and derived rates for one rule over the corpus.
class RuleMetrics {
  /// Creates a zeroed accumulator for [ruleId].
  RuleMetrics(this.ruleId);

  /// The rule these metrics describe.
  final String ruleId;

  /// Real violations the rule caught.
  int truePositives = 0;

  /// Findings the rule reported that were not real violations.
  int falsePositives = 0;

  /// Real violations the rule missed.
  int falseNegatives = 0;

  /// False positives that occurred specifically on clean cases (target: 0).
  int falsePositivesOnClean = 0;

  /// How many clean cases isolated this rule (the fpRateOnClean denominator).
  int cleanCases = 0;

  /// Of the findings reported, the fraction that were real. Undefined when the
  /// rule reported nothing; reported as 1.0 (a rule that says nothing is never
  /// wrong).
  double get precision {
    final reported = truePositives + falsePositives;
    return reported == 0 ? 1.0 : truePositives / reported;
  }

  /// Of the real violations, the fraction the rule caught. Undefined when there
  /// were none; reported as 1.0.
  double get recall {
    final real = truePositives + falseNegatives;
    return real == 0 ? 1.0 : truePositives / real;
  }

  /// The rate of false positives across the clean cases isolating this rule.
  double get fpRateOnClean =>
      cleanCases == 0 ? 0.0 : falsePositivesOnClean / cleanCases;

  /// The JSON representation of these metrics (tallies plus derived rates).
  Map<String, dynamic> toJson() => {
        'ruleId': ruleId,
        'truePositives': truePositives,
        'falsePositives': falsePositives,
        'falseNegatives': falseNegatives,
        'falsePositivesOnClean': falsePositivesOnClean,
        'cleanCases': cleanCases,
        'precision': precision,
        'recall': recall,
        'fpRateOnClean': fpRateOnClean,
      };

  /// Parses [RuleMetrics] from [json] (the derived rates are recomputed).
  factory RuleMetrics.fromJson(Map<String, dynamic> json) =>
      RuleMetrics(json['ruleId'] as String)
        ..truePositives = json['truePositives'] as int? ?? 0
        ..falsePositives = json['falsePositives'] as int? ?? 0
        ..falseNegatives = json['falseNegatives'] as int? ?? 0
        ..falsePositivesOnClean = json['falsePositivesOnClean'] as int? ?? 0
        ..cleanCases = json['cleanCases'] as int? ?? 0;
}

/// One reason the corpus gate failed.
class GateViolation {
  /// Creates a [GateViolation].
  const GateViolation(this.ruleId, this.kind, this.message);

  /// The rule at fault.
  final String ruleId;

  /// Which gate condition was breached.
  final GateViolationKind kind;

  /// A human-readable explanation.
  final String message;

  @override
  String toString() => '[$ruleId] $message';
}

/// The gate conditions a rule can breach.
enum GateViolationKind {
  /// A deterministic rule false-positived on the corpus (precision < 1.0).
  deterministicPrecision,

  /// A heuristic rule fell below its declared precision threshold.
  heuristicPrecision,

  /// A rule false-positived on a clean case.
  falsePositiveOnClean,

  /// A rule's recall regressed below the committed baseline.
  recallRegression,
}

/// The full corpus result: per-rule metrics plus authoring warnings.
class CorpusMetrics {
  /// Creates a [CorpusMetrics].
  const CorpusMetrics({required this.byRule, this.warnings = const []});

  /// Metrics keyed by rule id.
  final Map<String, RuleMetrics> byRule;

  /// Non-fatal authoring problems noticed while scoring (e.g. an expected
  /// finding whose identifier did not resolve).
  final List<String> warnings;

  /// The rules, in a stable (sorted) order.
  List<RuleMetrics> get rules => byRule.values.sortedBy((m) => m.ruleId);

  /// Evaluates the CI gate. Returns every breach; an empty list means the gate
  /// passes.
  ///
  /// It fails when: a deterministic rule has precision below 1.0; a heuristic
  /// rule has precision below its entry in [heuristicPrecisionThresholds]; any
  /// rule has a false positive on a clean case; or a rule's recall regressed
  /// more than [recallTolerance] below [baseline].
  List<GateViolation> gateViolations({
    required Map<String, Confidence> confidenceByRule,
    Map<String, double> heuristicPrecisionThresholds = const {},
    CorpusMetrics? baseline,
    double recallTolerance = 0.02,
  }) {
    final violations = <GateViolation>[];
    for (final metrics in rules) {
      final id = metrics.ruleId;
      final confidence = confidenceByRule[id] ?? Confidence.deterministic;

      if (metrics.falsePositivesOnClean > 0) {
        violations.add(
          GateViolation(
            id,
            GateViolationKind.falsePositiveOnClean,
            '${metrics.falsePositivesOnClean} false positive(s) on clean cases.',
          ),
        );
      }

      if (confidence == Confidence.deterministic) {
        if (metrics.precision < 1.0) {
          violations.add(
            GateViolation(
              id,
              GateViolationKind.deterministicPrecision,
              'deterministic precision is '
              '${metrics.precision.toStringAsFixed(3)} (< 1.0): '
              '${metrics.falsePositives} false positive(s).',
            ),
          );
        }
      } else {
        final threshold = heuristicPrecisionThresholds[id];
        if (threshold != null && metrics.precision < threshold) {
          violations.add(
            GateViolation(
              id,
              GateViolationKind.heuristicPrecision,
              'heuristic precision is '
              '${metrics.precision.toStringAsFixed(3)} '
              '(< declared ${threshold.toStringAsFixed(3)}).',
            ),
          );
        }
      }

      final priorRecall = baseline?.byRule[id]?.recall;
      if (priorRecall != null &&
          metrics.recall < priorRecall - recallTolerance) {
        violations.add(
          GateViolation(
            id,
            GateViolationKind.recallRegression,
            'recall dropped to ${metrics.recall.toStringAsFixed(3)} from a '
            'baseline of ${priorRecall.toStringAsFixed(3)}.',
          ),
        );
      }
    }
    return violations;
  }

  /// The JSON representation: a rule list plus any warnings.
  Map<String, dynamic> toJson() => {
        'rules': [for (final m in rules) m.toJson()],
        if (warnings.isNotEmpty) 'warnings': warnings,
      };

  /// Parses [CorpusMetrics] from [json] (used to load a committed baseline).
  factory CorpusMetrics.fromJson(Map<String, dynamic> json) {
    final rules = <String, RuleMetrics>{};
    for (final entry in (json['rules'] as List<dynamic>? ?? const [])) {
      final metrics = RuleMetrics.fromJson(entry as Map<String, dynamic>);
      rules[metrics.ruleId] = metrics;
    }
    return CorpusMetrics(
      byRule: Map.unmodifiable(rules),
      warnings: [
        for (final w in (json['warnings'] as List<dynamic>? ?? const []))
          w as String,
      ],
    );
  }

  /// A fixed-width table for humans, one row per rule.
  String renderTable() {
    final buffer = StringBuffer()
      ..writeln(
        'rule                            TP  FP  FN  prec.  recall  fp/clean',
      )
      ..writeln(
        '--------------------------------------------------------------------',
      );
    for (final m in rules) {
      buffer.writeln(
        '${m.ruleId.padRight(30)}  '
        '${m.truePositives.toString().padLeft(2)}  '
        '${m.falsePositives.toString().padLeft(2)}  '
        '${m.falseNegatives.toString().padLeft(2)}  '
        '${m.precision.toStringAsFixed(2).padLeft(5)}  '
        '${m.recall.toStringAsFixed(2).padLeft(6)}  '
        '${m.fpRateOnClean.toStringAsFixed(2).padLeft(8)}',
      );
    }
    return buffer.toString();
  }
}
