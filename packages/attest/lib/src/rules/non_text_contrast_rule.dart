import '../engine/fingerprint.dart';
import '../engine/rule.dart';
import '../model/confidence.dart';
import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import 'criteria.dart';

/// Flags icons and other non-text glyphs whose contrast against their
/// background is below the WCAG 1.4.11 minimum of 3:1.
///
/// Reads the non-text samples the raster collector marks (an icon renders as a
/// glyph, so it is measured from pixels the same way text is, but held to the
/// flat 3:1 non-text minimum rather than the size-dependent text minimum). A
/// pure-Dart snapshot carries no samples and the rule yields nothing. Disabled
/// controls are exempt, and ratios just below the threshold are downgraded to a
/// warning because pixel sampling is inherently noisy.
class NonTextContrastRule implements Rule {
  /// Creates a [NonTextContrastRule].
  const NonTextContrastRule();

  /// The 1.4.11 minimum contrast ratio for non-text content.
  static const double _minimumRatio = 3.0;

  /// The width of the borderline band, just under the threshold, reported as a
  /// warning rather than an error.
  static const double _borderlineBand = 0.2;

  @override
  String get id => 'attest/non-text-contrast';

  @override
  Criterion get criterion => Criteria.nonTextContrast;

  @override
  Severity get defaultSeverity => Severity.error;

  @override
  Confidence get confidence => Confidence.deterministic;

  @override
  Iterable<Finding> evaluate(
    SemanticsSnapshot snapshot,
    RuleContext context,
  ) sync* {
    for (final sample in snapshot.contrastSamples) {
      if (!sample.isNonText) continue;
      if (sample.isDisabled) continue;
      final ratio = sample.contrastRatio;
      if (ratio >= _minimumRatio) continue;

      final severity = ratio >= _minimumRatio - _borderlineBand
          ? Severity.warning
          : Severity.error;

      yield Finding(
        ruleId: id,
        criterion: criterion,
        severity: severity,
        confidence: confidence,
        message: 'Icon / graphical contrast is ${ratio.toStringAsFixed(1)}:1; '
            'non-text content needs at least '
            '${_minimumRatio.toStringAsFixed(1)}:1.',
        suggestion:
            'Darken the icon colour or lighten the background until the ratio '
            'meets the minimum.',
        fingerprint: Fingerprinter.compute(
          ruleId: id,
          wcag: criterion.wcag,
          nodePath: 'non-text-contrast',
          label: sample.label,
        ),
        identifier: sample.identifier,
        bounds: sample.bounds,
      );
    }
  }
}
