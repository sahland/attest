import '../engine/rule.dart';
import '../model/confidence.dart';
import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/semantics_flag.dart';
import '../model/semantics_node_data.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import 'criteria.dart';

/// Flags form controls — text fields, checkboxes, switches, radios — that have
/// no programmatic label.
///
/// A placeholder / hint does **not** count as a label: it is not announced as the
/// field's name and disappears once the user types, so a node whose only text is
/// a hint is still a violation.
class FieldLabelRule implements Rule {
  /// Creates a [FieldLabelRule].
  const FieldLabelRule();

  @override
  String get id => 'attest/field-label';

  @override
  Criterion get criterion => Criteria.infoAndRelationships;

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
      if (!_isFormControl(node)) continue;
      if (node.label.trim().isNotEmpty) continue;
      yield context.report(
        this,
        node,
        label: _kind(node),
        message:
            'Form control (${_kind(node)}) has no label; a screen reader cannot '
            'say what it is for. A hint or placeholder does not count as a label.',
        suggestion:
            'Provide InputDecoration(labelText: …) for fields, or wrap the '
            'control in Semantics(label: …) and associate it with its caption.',
      );
    }
  }

  bool _isFormControl(SemanticsNodeData node) =>
      node.hasFlag(SemanticsFlagData.isTextField) ||
      node.hasFlag(SemanticsFlagData.hasCheckedState) ||
      node.hasFlag(SemanticsFlagData.hasToggledState);

  String _kind(SemanticsNodeData node) {
    if (node.hasFlag(SemanticsFlagData.isTextField)) return 'text field';
    if (node.hasFlag(SemanticsFlagData.hasToggledState)) return 'switch';
    if (node.hasFlag(SemanticsFlagData.hasCheckedState)) return 'checkbox';
    return 'control';
  }
}
