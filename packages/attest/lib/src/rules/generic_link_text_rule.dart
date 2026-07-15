import '../engine/rule.dart';
import '../model/confidence.dart';
import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/semantics_flag.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import 'criteria.dart';

/// Flags links whose accessible name is a generic phrase that does not describe
/// where they go.
///
/// "Read more", "click here" and the like force a screen-reader user — who often
/// navigates by pulling up a list of links out of context — to guess each
/// destination. WCAG 2.4.4 allows the purpose to be clear from the surrounding
/// context, so this is a heuristic: it ships as a suppressible warning and only
/// fires on actual links (not buttons) whose whole name is a known generic
/// phrase.
class GenericLinkTextRule implements Rule {
  /// Creates a [GenericLinkTextRule].
  const GenericLinkTextRule();

  /// Accessible names that describe no destination, compared case-insensitively
  /// against a link's whole label once edge decoration is stripped (see
  /// [_core]).
  static const Set<String> _genericPhrases = {
    'click here',
    'click',
    'tap here',
    'read more',
    'read',
    'learn more',
    'more',
    'more info',
    'see more',
    'details',
    'here',
    'link',
    'this link',
    'continue reading',
    'go',
  };

  @override
  String get id => 'attest/generic-link-text';

  @override
  Criterion get criterion => Criteria.linkPurpose;

  @override
  Severity get defaultSeverity => Severity.warning;

  @override
  Confidence get confidence => Confidence.heuristic;

  /// Edge decoration developers append to generic link text without making it
  /// describe anything: trailing ellipses and arrows (`Read more…`, `More ›`),
  /// leading bullets, surrounding punctuation. Matched at either end only, so
  /// internal text is never altered.
  static final RegExp _edgeDecoration = RegExp(
    r'^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$',
    unicode: true,
  );

  static final RegExp _innerWhitespace = RegExp(r'\s+');

  /// The comparable core of [label]: lower-cased, edge decoration removed and
  /// internal whitespace collapsed. `"Read more…"`, `"READ MORE"` and
  /// `"read  more"` all reduce to `read more`.
  ///
  /// Only leading/trailing non-alphanumeric runs are stripped, so a link whose
  /// visible text is genuinely descriptive can never collapse onto a generic
  /// phrase — its internal words survive untouched.
  static String _core(String label) => label
      .toLowerCase()
      .replaceAll(_edgeDecoration, '')
      .replaceAll(_innerWhitespace, ' ')
      .trim();

  @override
  Iterable<Finding> evaluate(
    SemanticsSnapshot snapshot,
    RuleContext context,
  ) sync* {
    for (final node in snapshot.allNodes) {
      if (!node.hasFlag(SemanticsFlagData.isLink)) continue;
      final label = _core(node.label);
      if (label.isEmpty) continue;
      if (!_genericPhrases.contains(label)) continue;
      yield context.report(
        this,
        node,
        message: 'Link text "${node.label}" does not describe its destination; '
            'out of context a screen-reader user cannot tell where it goes.',
        suggestion: 'Use link text that names the target — for example '
            '"Read the 2026 report" instead of "Read more".',
      );
    }
  }
}
