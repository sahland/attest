import '../engine/rule.dart';
import '../model/confidence.dart';
import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/semantics_action.dart';
import '../model/semantics_node_data.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import 'criteria.dart';

/// Flags adjustable controls — sliders, steppers — that expose no current
/// value.
///
/// A node that responds to the increase or decrease action is an adjustable
/// control. WCAG 4.1.2 requires its value to be programmatically determinable:
/// without one, a screen reader lets the user change the setting but never says
/// what it currently is. A visible label is not the value ("Volume" does not
/// tell you it is at 50%), so a labelled slider with no value still fails.
class AdjustableValueRule implements Rule {
  /// Creates an [AdjustableValueRule].
  const AdjustableValueRule();

  @override
  String get id => 'attest/adjustable-value';

  @override
  Criterion get criterion => Criteria.nameRoleValue;

  @override
  Severity get defaultSeverity => Severity.error;

  @override
  Confidence get confidence => Confidence.deterministic;

  @override
  Iterable<Finding> evaluate(
    SemanticsSnapshot snapshot,
    RuleContext context,
  ) sync* {
    for (final node in snapshot.allNodes) {
      if (!_isAdjustable(node)) continue;
      if (node.value.trim().isNotEmpty) continue;
      yield context.report(
        this,
        node,
        label: 'adjustable',
        message: 'Adjustable control exposes no value; a screen reader can '
            'change the setting but cannot announce its current value.',
        suggestion:
            "Expose the current value via Semantics(value: '…') — for example "
            'the slider position as "50%" — separate from its label.',
        codeExample: '// Before — the control adjusts but announces no value\n'
            'Slider(value: _volume, onChanged: _setVolume)\n\n'
            '// After — expose the current value to a screen reader\n'
            'Semantics(\n'
            "  value: '\${(_volume * 100).round()}%',\n"
            '  child: Slider(value: _volume, onChanged: _setVolume),\n'
            ')',
      );
    }
  }

  bool _isAdjustable(SemanticsNodeData node) =>
      node.hasAction(SemanticsActionData.increase) ||
      node.hasAction(SemanticsActionData.decrease);
}
