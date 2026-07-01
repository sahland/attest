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

/// Flags a group of custom tappable controls that expose no selected state.
///
/// Two or more sibling gesture controls that share no role (not a button, link
/// or field) and none of which is selectable look like a hand-built segmented
/// control, tab bar or chip group whose state was never surfaced to assistive
/// technology. This is a heuristic — a pair of custom nav targets can trip it —
/// so it stays silent if any sibling already exposes state and ships as a
/// suppressible warning.
class StateExposedRule implements Rule {
  /// Creates a [StateExposedRule].
  const StateExposedRule();

  /// The smallest sibling group treated as a selectable set.
  static const int _minimumGroupSize = 2;

  @override
  String get id => 'attest/state-exposed';

  @override
  Criterion get criterion => Criteria.nameRoleValue;

  @override
  Severity get defaultSeverity => Severity.warning;

  @override
  Confidence get confidence => Confidence.heuristic;

  @override
  Iterable<Finding> evaluate(
    SemanticsSnapshot snapshot,
    RuleContext context,
  ) sync* {
    for (final parent in snapshot.allNodes) {
      final group =
          parent.childrenInTraversalOrder.where(_isCustomTappable).toList();
      if (group.length < _minimumGroupSize) continue;
      if (group.any(_exposesState)) continue;

      for (final node in group) {
        yield context.report(
          this,
          node,
          label: 'state-exposed',
          message:
              'This looks like one of a group of custom selectable controls, '
              'but its selected/toggled state is not exposed to assistive '
              'technology.',
          suggestion: 'Propagate the state via Semantics(selected: true) or '
              'Semantics(toggled: true).',
        );
      }
    }
  }

  bool _isCustomTappable(SemanticsNodeData node) =>
      node.hasAction(SemanticsActionData.tap) &&
      !node.hasFlag(SemanticsFlagData.isButton) &&
      !node.hasFlag(SemanticsFlagData.isLink) &&
      !node.hasFlag(SemanticsFlagData.isTextField);

  bool _exposesState(SemanticsNodeData node) =>
      node.hasFlag(SemanticsFlagData.hasCheckedState) ||
      node.hasFlag(SemanticsFlagData.hasToggledState) ||
      node.hasFlag(SemanticsFlagData.isSelected);
}
