import 'dart:math' as math;

import '../engine/rule.dart';
import '../model/confidence.dart';
import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/semantics_node_data.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import 'criteria.dart';

/// Flags screens whose layout overflows when the system text size is enlarged.
///
/// This is the Flutter-specific killer check: a large system font routinely
/// breaks a `Row` or `Column` (`RenderFlex overflowed`), and web accessibility
/// tools cannot see it. The rule reads the observations gathered by the
/// text-scale collector; a pure-Dart snapshot carries none and the rule yields
/// nothing.
class TextOverflowRule implements Rule {
  /// Creates a [TextOverflowRule].
  const TextOverflowRule();

  @override
  String get id => 'attest/text-overflow';

  @override
  Criterion get criterion => Criteria.resizeText;

  @override
  Severity get defaultSeverity => Severity.error;

  @override
  Confidence get confidence => Confidence.deterministic;

  @override
  Iterable<Finding> evaluate(
    SemanticsSnapshot snapshot,
    RuleContext context,
  ) sync* {
    // Group overflow observations by the node they implicate (the root when the
    // collector could not attribute the overflow), keeping the smallest scale at
    // which the overflow first appears.
    final smallestScaleByNode = <int, double>{};
    for (final observation in snapshot.textScaleObservations) {
      if (!observation.overflowed) continue;
      final nodeId = observation.nodeId ?? snapshot.root.id;
      smallestScaleByNode[nodeId] = math.min(
        smallestScaleByNode[nodeId] ?? observation.textScale,
        observation.textScale,
      );
    }

    for (final entry in smallestScaleByNode.entries) {
      final node = _nodeById(snapshot, entry.key) ?? snapshot.root;
      final scale = entry.value;
      yield context.report(
        this,
        node,
        label: 'text-overflow',
        message: 'Layout overflows when text is scaled to ${_format(scale)}×; '
            'content is clipped or cut off at larger system font sizes.',
        suggestion:
            'Allow the content to wrap or scroll: use Flexible/Expanded, '
            'FittedBox, or drop fixed heights.',
      );
    }
  }

  SemanticsNodeData? _nodeById(SemanticsSnapshot snapshot, int id) {
    for (final node in snapshot.allNodes) {
      if (node.id == id) return node;
    }
    return null;
  }

  String _format(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';
}
