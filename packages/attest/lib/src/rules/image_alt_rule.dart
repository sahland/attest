import '../engine/rule.dart';
import '../model/confidence.dart';
import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/semantics_flag.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import 'criteria.dart';

/// Flags images that are visible to assistive technology but carry no text
/// alternative.
///
/// A correctly decorative image is excluded from the semantics tree entirely
/// (e.g. via `ExcludeSemantics`) and so never reaches the snapshot; therefore
/// only a semantics-visible image with an empty label is a violation.
///
/// Interactive images (an icon button, say) are left to the interactive-name
/// rule, so the two never report the same node.
class ImageAltRule implements Rule {
  /// Creates an [ImageAltRule].
  const ImageAltRule();

  @override
  String get id => 'attest/image-alt';

  @override
  Criterion get criterion => Criteria.nonTextContent;

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
      if (!node.hasFlag(SemanticsFlagData.isImage)) continue;
      if (node.isInteractive) continue;
      if (node.label.trim().isNotEmpty) continue;
      yield context.report(
        this,
        node,
        label: 'image',
        message:
            'Image has no text alternative; a screen reader cannot describe it.',
        suggestion:
            "Provide Image(…, semanticLabel: '…'), or wrap a purely decorative "
            'image in ExcludeSemantics.',
      );
    }
  }
}
