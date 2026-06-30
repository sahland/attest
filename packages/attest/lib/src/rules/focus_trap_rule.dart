import '../engine/rule.dart';
import '../model/confidence.dart';
import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/semantics_flag.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import 'criteria.dart';

/// Flags interactive elements that are reachable by touch but hidden from
/// assistive technology.
///
/// A node that is tappable yet carries the `isHidden` flag exists for a sighted
/// user but is unreachable by a screen reader or keyboard. (The related case of
/// an element removed from the tree by `ExcludeSemantics` cannot be seen in the
/// snapshot at all, so it is out of this rule's reach.)
class FocusTrapRule implements Rule {
  /// Creates a [FocusTrapRule].
  const FocusTrapRule();

  @override
  String get id => 'attest/focus-trap';

  @override
  Criterion get criterion => Criteria.keyboard;

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
      if (!node.isInteractive) continue;
      if (!node.hasFlag(SemanticsFlagData.isHidden)) continue;
      yield context.report(
        this,
        node,
        label: 'hidden-interactive',
        message: 'Interactive element is tappable but hidden from assistive '
            'technology, so a screen-reader or keyboard user cannot reach it.',
        suggestion:
            'Remove the erroneous ExcludeSemantics / hidden flag, or make the '
            'element genuinely non-interactive.',
      );
    }
  }
}
