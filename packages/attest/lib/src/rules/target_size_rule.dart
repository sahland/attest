import '../engine/rule.dart';
import '../model/confidence.dart';
import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/semantics_action.dart';
import '../model/semantics_flag.dart';
import '../model/semantics_node_data.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import 'criteria.dart';

/// Flags touch targets smaller than the configured minimum.
///
/// The threshold comes from `RuleConfig` — platform guidance (48 logical px for
/// Material, 44 for iOS) by default, or the strict WCAG 2.5.8 minimum of 24.
/// Inline links and hidden nodes are exempt. Reported as a warning because
/// WCAG 2.5.8 also exempts targets with adequate spacing, which a future pass
/// will account for.
class TargetSizeRule implements Rule {
  /// Creates a [TargetSizeRule].
  const TargetSizeRule();

  @override
  String get id => 'attest/target-size';

  @override
  Criterion get criterion => Criteria.targetSize;

  @override
  Severity get defaultSeverity => Severity.warning;

  @override
  Confidence get confidence => Confidence.deterministic;

  @override
  Iterable<Finding> evaluate(
    SemanticsSnapshot snapshot,
    RuleContext context,
  ) sync* {
    final minimum = context.config.minimumTargetSize;
    for (final node in snapshot.allNodes) {
      if (!_appliesTo(node)) continue;
      final size = node.bounds.shortestSide;
      if (size <= 0 || size >= minimum) continue;
      yield context.report(
        this,
        node,
        label: 'target',
        message: 'Touch target is ${_format(node.bounds.width)}×'
            '${_format(node.bounds.height)} logical px; the minimum is '
            '${_format(minimum)}×${_format(minimum)}.',
        suggestion:
            'Add padding or a SizedBox, or use MaterialTapTargetSize.padded, to '
            'reach the minimum target size.',
      );
    }
  }

  bool _appliesTo(SemanticsNodeData node) =>
      node.hasAction(SemanticsActionData.tap) &&
      !node.hasFlag(SemanticsFlagData.isLink) &&
      !node.hasFlag(SemanticsFlagData.isHidden);

  String _format(double value) => value.toStringAsFixed(0);
}
