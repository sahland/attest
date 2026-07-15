import '../engine/rule.dart';
import '../model/confidence.dart';
import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/semantics_flag.dart';
import '../model/semantics_node_data.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import 'criteria.dart';

/// Flags interactive elements that expose no accessible name.
///
/// A screen reader announces such an element as a bare "button", giving no clue
/// what it does — the most frequent and most severe accessibility defect.
///
/// Text fields and checkable/toggleable controls are intentionally left to the
/// field-label rule, so the two never report the same node.
class InteractiveNameRule implements Rule {
  /// Creates an [InteractiveNameRule].
  const InteractiveNameRule();

  @override
  String get id => 'attest/interactive-name';

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
      if (!_appliesTo(node)) continue;
      if (_isNamed(node) || _hasNamingDescendant(node)) continue;
      yield context.report(
        this,
        node,
        label: 'button',
        message: 'Interactive element has no accessible name; a screen reader '
            'announces only its role.',
        suggestion:
            "Wrap it in Semantics(label: '…', button: true, child: …) or use "
            'IconButton(tooltip: …).',
        codeExample: '// Before — a screen reader announces only "button"\n'
            'IconButton(icon: Icon(Icons.share), onPressed: _share)\n\n'
            '// After — give it an accessible name\n'
            "IconButton(icon: Icon(Icons.share), tooltip: 'Share', "
            'onPressed: _share)',
      );
    }
  }

  bool _appliesTo(SemanticsNodeData node) =>
      node.isInteractive &&
      !node.hasFlag(SemanticsFlagData.isTextField) &&
      !node.hasFlag(SemanticsFlagData.hasCheckedState) &&
      !node.hasFlag(SemanticsFlagData.hasToggledState);

  bool _isNamed(SemanticsNodeData node) =>
      node.label.trim().isNotEmpty || node.tooltip.trim().isNotEmpty;

  bool _hasNamingDescendant(SemanticsNodeData node) =>
      node.childrenInTraversalOrder.any(
        (child) => child.selfAndDescendants.any(_isNamed),
      );
}
