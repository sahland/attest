import '../model/audit_meta.dart';
import '../model/audit_report.dart';
import '../model/finding.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import '../rules/ambiguous_name_rule.dart';
import '../rules/field_label_rule.dart';
import '../rules/focus_trap_rule.dart';
import '../rules/image_alt_rule.dart';
import '../rules/interactive_name_rule.dart';
import '../rules/placeholder_name_rule.dart';
import '../rules/target_size_rule.dart';
import '../rules/text_overflow_rule.dart';
import 'rule.dart';
import 'rule_config.dart';
import 'snapshot_index.dart';

/// Runs a set of [Rule]s over a [SemanticsSnapshot] and assembles an
/// [AuditReport].
class RuleEngine {
  /// Creates an engine that runs exactly [rules].
  const RuleEngine(this.rules);

  /// Creates an engine with the bundled TREE rules enabled.
  factory RuleEngine.standard() => const RuleEngine([
        InteractiveNameRule(),
        ImageAltRule(),
        PlaceholderNameRule(),
        FieldLabelRule(),
        TargetSizeRule(),
        FocusTrapRule(),
        AmbiguousNameRule(),
        TextOverflowRule(),
      ]);

  /// The rules this engine evaluates, in order.
  final List<Rule> rules;

  /// Evaluates every rule over [snapshot] and returns a report.
  ///
  /// Findings are sorted by rule id then fingerprint, so the output order is
  /// deterministic regardless of the order rules happen to emit them.
  AuditReport run(
    SemanticsSnapshot snapshot, {
    required AuditMeta meta,
    RuleConfig config = const RuleConfig(),
    Severity gateSeverity = Severity.error,
  }) {
    final context = RuleContext(
      config: config,
      index: SnapshotIndex.build(snapshot),
    );

    final findings = <Finding>[
      for (final rule in rules) ...rule.evaluate(snapshot, context),
    ]..sort(_byRuleThenFingerprint);

    return AuditReport(
      findings: List.unmodifiable(findings),
      meta: meta,
      gateSeverity: gateSeverity,
    );
  }

  static int _byRuleThenFingerprint(Finding a, Finding b) {
    final byRule = a.ruleId.compareTo(b.ruleId);
    return byRule != 0 ? byRule : a.fingerprint.compareTo(b.fingerprint);
  }
}
