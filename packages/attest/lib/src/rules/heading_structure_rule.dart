import '../engine/rule.dart';
import '../model/confidence.dart';
import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/semantics_flag.dart';
import '../model/semantics_node_data.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import 'criteria.dart';

/// Flags text that looks like a heading but is not exposed as one.
///
/// A large or bold title that carries no `header` semantics is announced as
/// ordinary text, so screen-reader users lose the ability to navigate by
/// heading. This is a heuristic — visual prominence is only a guess at intent —
/// so it is a suppressible warning, and it stays silent once any node on the
/// screen is a header (the developer clearly knows about heading semantics).
class HeadingStructureRule implements Rule {
  /// Creates a [HeadingStructureRule].
  const HeadingStructureRule();

  /// Minimum font size (logical px) for bold text to read as a heading.
  static const double _boldHeadingMinSize = 20;

  /// Minimum font size (logical px) for non-bold text to read as a heading.
  static const double _plainHeadingMinSize = 24;

  @override
  String get id => 'attest/heading-structure';

  @override
  Criterion get criterion => Criteria.infoAndRelationships;

  @override
  Severity get defaultSeverity => Severity.warning;

  @override
  Confidence get confidence => Confidence.heuristic;

  @override
  Iterable<Finding> evaluate(
    SemanticsSnapshot snapshot,
    RuleContext context,
  ) sync* {
    final hasAnyHeader = snapshot.allNodes.any(
      (node) => node.hasFlag(SemanticsFlagData.isHeader),
    );
    if (hasAnyHeader) return;

    for (final node in snapshot.allNodes) {
      if (!_looksLikeHeading(node)) continue;
      yield context.report(
        this,
        node,
        message:
            'Text "${node.label}" looks like a heading (large or bold) but is '
            'not exposed as one, so it cannot be navigated to as a heading.',
        suggestion: 'Wrap it in Semantics(header: true, child: …).',
      );
    }
  }

  bool _looksLikeHeading(SemanticsNodeData node) {
    final style = node.textStyle;
    if (style == null || node.label.trim().isEmpty) return false;
    final size = style.fontSize ?? 0;
    return (style.isBold && size >= _boldHeadingMinSize) ||
        size >= _plainHeadingMinSize;
  }
}
