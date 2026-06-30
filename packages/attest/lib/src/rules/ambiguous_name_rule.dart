import '../engine/rule.dart';
import '../model/confidence.dart';
import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/semantics_node_data.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import 'criteria.dart';

/// Flags interactive elements on a screen that share an identical accessible
/// name.
///
/// Two "Delete" buttons with nothing to tell them apart leave a screen-reader
/// user guessing which is which. This is a heuristic: legitimately repeated
/// controls (a list of identical "Add" buttons) can trip it, so it ships as a
/// warning that is easy to suppress.
class AmbiguousNameRule implements Rule {
  /// Creates an [AmbiguousNameRule].
  const AmbiguousNameRule();

  @override
  String get id => 'attest/ambiguous-name';

  @override
  Criterion get criterion => Criteria.headingsAndLabels;

  @override
  Severity get defaultSeverity => Severity.warning;

  @override
  Confidence get confidence => Confidence.heuristic;

  @override
  Iterable<Finding> evaluate(
    SemanticsSnapshot snapshot,
    RuleContext context,
  ) sync* {
    final byLabel = <String, List<SemanticsNodeData>>{};
    for (final node in snapshot.allNodes) {
      if (!node.isInteractive) continue;
      final label = node.label.trim();
      if (label.isEmpty) continue;
      byLabel.putIfAbsent(label.toLowerCase(), () => []).add(node);
    }

    for (final group in byLabel.values) {
      if (group.length < 2) continue;
      for (final node in group) {
        yield context.report(
          this,
          node,
          message: 'Multiple interactive elements share the accessible name '
              '"${node.label}"; a screen-reader user cannot tell them apart.',
          suggestion:
              'Qualify each label, e.g. "Delete photo" and "Delete account".',
        );
      }
    }
  }
}
