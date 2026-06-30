import '../engine/rule.dart';
import '../model/confidence.dart';
import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/semantics_flag.dart';
import '../model/semantics_node_data.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import 'criteria.dart';

/// Flags meaningful elements whose accessible name is a generic placeholder.
///
/// A name like "button", "image" or "untitled" passes the presence checks but
/// tells a screen-reader user nothing. The denylist is configurable via
/// [RuleConfig.placeholderDenylist].
class PlaceholderNameRule implements Rule {
  /// Creates a [PlaceholderNameRule].
  const PlaceholderNameRule();

  @override
  String get id => 'attest/placeholder-name';

  @override
  Criterion get criterion => Criteria.headingsAndLabels;

  @override
  Severity get defaultSeverity => Severity.warning;

  @override
  Confidence get confidence => Confidence.deterministic;

  @override
  Iterable<Finding> evaluate(
    SemanticsSnapshot snapshot,
    RuleContext context,
  ) sync* {
    final denylist = context.config.placeholderDenylist;
    for (final node in snapshot.allNodes) {
      if (!_isNameable(node)) continue;
      final label = node.label.trim();
      if (label.isEmpty) continue;
      if (!denylist.contains(label.toLowerCase())) continue;
      yield context.report(
        this,
        node,
        message:
            'Accessible name "${node.label}" is a generic placeholder that does '
            'not describe the element.',
        suggestion: 'Give the element a meaningful, specific label.',
      );
    }
  }

  bool _isNameable(SemanticsNodeData node) =>
      node.isInteractive ||
      node.hasFlag(SemanticsFlagData.isImage) ||
      node.hasFlag(SemanticsFlagData.isTextField) ||
      node.hasFlag(SemanticsFlagData.isHeader);
}
