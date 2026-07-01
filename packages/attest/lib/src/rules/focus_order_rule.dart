import '../engine/rule.dart';
import '../model/confidence.dart';
import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import 'criteria.dart';

/// Flags an illogical focus order: an element reached later in traversal that
/// sits entirely above the element reached just before it.
///
/// Comparing traversal order to visual position is a heuristic, so this only
/// fires on a clear vertical inversion (reading jumps upward), and ships as a
/// suppressible warning.
class FocusOrderRule implements Rule {
  /// Creates a [FocusOrderRule].
  const FocusOrderRule();

  @override
  String get id => 'attest/focus-order';

  @override
  Criterion get criterion => Criteria.focusOrder;

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
      final children = parent.childrenInTraversalOrder;
      for (var i = 0; i < children.length - 1; i++) {
        final earlier = children[i];
        final later = children[i + 1];
        if (earlier.bounds.isEmpty || later.bounds.isEmpty) continue;
        // `later` is reached next but sits entirely above `earlier`.
        if (later.bounds.bottom <= earlier.bounds.top) {
          yield context.report(
            this,
            later,
            label: 'focus-order',
            message:
                'Focus order is illogical: this element is reached after one '
                'positioned below it, so traversal jumps upward.',
            suggestion: 'Order traversal with FocusTraversalGroup or '
                'Semantics(sortKey: OrdinalSortKey(…)).',
          );
        }
      }
    }
  }
}
