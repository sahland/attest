import '../model/confidence.dart';
import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/semantics_node_data.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import 'fingerprint.dart';
import 'rule_config.dart';
import 'snapshot_index.dart';

/// A single accessibility check.
///
/// A rule is a pure, stateless, deterministic function over a
/// [SemanticsSnapshot]: given the same snapshot and [RuleContext] it must always
/// yield the same findings. It must bind to a [criterion] — a check with no
/// citable standard clause is not allowed.
abstract interface class Rule {
  /// The stable rule id, e.g. `attest/interactive-name`.
  String get id;

  /// The standard clause this rule enforces.
  Criterion get criterion;

  /// The severity findings get unless configuration overrides it.
  Severity get defaultSeverity;

  /// How much to trust this rule's findings.
  Confidence get confidence;

  /// Inspects [snapshot] and yields zero or more findings.
  Iterable<Finding> evaluate(SemanticsSnapshot snapshot, RuleContext context);
}

/// The shared state a rule reads while evaluating: the [config] and the
/// precomputed [index], plus helpers for building findings.
class RuleContext {
  /// Creates a [RuleContext].
  const RuleContext({required this.config, required this.index});

  /// The active configuration.
  final RuleConfig config;

  /// Precomputed lookups over the snapshot being evaluated.
  final SnapshotIndex index;

  /// Builds a [Finding] for [rule] anchored to [node], filling in the rule's
  /// criterion, confidence and severity, the node's source location and bounds,
  /// and a stable fingerprint.
  ///
  /// Pass [label] to fingerprint against something other than the node's own
  /// label (e.g. a derived role name); pass [severity] to override the rule's
  /// default.
  Finding report(
    Rule rule,
    SemanticsNodeData node, {
    required String message,
    required String suggestion,
    Severity? severity,
    String? label,
  }) {
    return Finding(
      ruleId: rule.id,
      criterion: rule.criterion,
      severity: severity ?? rule.defaultSeverity,
      confidence: rule.confidence,
      message: message,
      suggestion: suggestion,
      fingerprint: Fingerprinter.compute(
        ruleId: rule.id,
        wcag: rule.criterion.wcag,
        nodePath: index.pathOf(node),
        label: label ?? node.label,
      ),
      location: node.creator,
      bounds: node.bounds,
    );
  }
}
