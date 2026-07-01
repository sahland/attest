import '../engine/fingerprint.dart';
import '../engine/rule.dart';
import '../model/confidence.dart';
import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/semantics_snapshot.dart';
import '../model/severity.dart';
import 'criteria.dart';

/// Flags text whose contrast against its background is below the WCAG minimum.
///
/// Reads the samples gathered by the raster collector; a pure-Dart snapshot has
/// none and the rule yields nothing. Normal text needs a ratio of at least
/// 4.5:1 and large text at least 3:1. Disabled controls are exempt (WCAG 1.4.3
/// excludes them), and ratios just below the threshold are downgraded to a
/// warning because pixel sampling over gradients and images is false-positive
/// prone.
class ContrastRule implements Rule {
  /// Creates a [ContrastRule].
  const ContrastRule();

  /// The width of the borderline band, just under the threshold, that is
  /// reported as a warning rather than an error.
  static const double _borderlineBand = 0.2;

  @override
  String get id => 'attest/contrast';

  @override
  Criterion get criterion => Criteria.contrastMinimum;

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
      if (sample.isDisabled) continue;
      final threshold = sample.isLargeText ? 3.0 : 4.5;
      final ratio = sample.contrastRatio;
      if (ratio >= threshold) continue;

      final severity = ratio >= threshold - _borderlineBand
          ? Severity.warning
          : Severity.error;

      yield Finding(
        ruleId: id,
        criterion: criterion,
        severity: severity,
        confidence: confidence,
        message: 'Text contrast is ${ratio.toStringAsFixed(1)}:1; '
            '${sample.isLargeText ? 'large' : 'normal'} text needs at least '
            '${threshold.toStringAsFixed(1)}:1.',
        suggestion:
            'Darken the text colour or lighten the background until the ratio '
            'meets the minimum.',
        fingerprint: Fingerprinter.compute(
          ruleId: id,
          wcag: criterion.wcag,
          nodePath: 'contrast',
          label: sample.label,
        ),
        bounds: sample.bounds,
      );
    }
  }
}
