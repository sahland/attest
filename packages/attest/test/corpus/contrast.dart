import 'support.dart';

const _rule = 'attest/contrast';
const _wcag = '1.4.3';

// A generic text rect; contrast findings anchor on the sample's identifier, not
// on a tree node.
final _bounds = rect(0, 0, 120, 20);

ContrastSample _sample(
  String identifier, {
  required double fg,
  required double bg,
  double? fontSize,
  bool isBold = false,
  bool isDisabled = false,
}) =>
    ContrastSample(
      identifier: identifier,
      label: identifier,
      foregroundLuminance: fg,
      backgroundLuminance: bg,
      bounds: _bounds,
      fontSize: fontSize,
      isBold: isBold,
      isDisabled: isDisabled,
    );

/// Corpus for `attest/contrast` (WCAG 1.4.3): text must meet 4.5:1 (normal) or
/// 3:1 (large). Ratios are `(hi + 0.05) / (lo + 0.05)` of the relative
/// luminances.
final List<CorpusCase> contrastCases = [
  // --- positive ---
  positive(
    'contrast/low_contrast_normal_text',
    _rule,
    // ratio (0.05+0.05)/(0.0+0.05) = 2.0, well under 4.5.
    snap(
      node(),
      contrastSamples: [
        _sample('off.normal', fg: 0.0, bg: 0.05, fontSize: 14),
      ],
    ),
    [ef(_rule, _wcag, 'off.normal')],
  ),
  positive(
    'contrast/low_contrast_large_text',
    _rule,
    // Large text needs only 3:1; 1.4 still fails.
    snap(
      node(),
      contrastSamples: [
        _sample('off.large', fg: 0.0, bg: 0.02, fontSize: 30),
      ],
    ),
    [ef(_rule, _wcag, 'off.large')],
  ),
  positive(
    'contrast/borderline_downgraded_to_warning',
    _rule,
    // ratio ~4.2: below 4.5 but within the borderline band -> a warning finding.
    snap(
      node(),
      contrastSamples: [
        _sample('off.borderline', fg: 0.0, bg: 0.16, fontSize: 14),
      ],
    ),
    [ef(_rule, _wcag, 'off.borderline')],
  ),
  positive(
    'contrast/bold_large_text_fails',
    _rule,
    // Bold >= 18.66px counts as large (3:1); 1.6 fails.
    snap(
      node(),
      contrastSamples: [
        _sample('off.bold', fg: 0.0, bg: 0.03, fontSize: 20, isBold: true),
      ],
    ),
    [ef(_rule, _wcag, 'off.bold')],
  ),

  // --- clean ---
  clean(
    'contrast/sufficient_normal_text',
    _rule,
    // ratio 5.0 passes 4.5.
    snap(
      node(),
      contrastSamples: [
        _sample('ok.normal', fg: 0.0, bg: 0.2, fontSize: 14),
      ],
    ),
  ),
  clean(
    'contrast/sufficient_large_text',
    _rule,
    // ratio exactly 3.0 meets the large-text minimum.
    snap(
      node(),
      contrastSamples: [_sample('ok.large', fg: 0.0, bg: 0.1, fontSize: 30)],
    ),
  ),

  // --- adversarial ---
  adversarial(
    'contrast/disabled_control_exempt',
    _rule,
    // WCAG 1.4.3 exempts disabled controls, even at a failing ratio.
    snap(
      node(),
      contrastSamples: [
        _sample(
          'trap.disabled',
          fg: 0.0,
          bg: 0.05,
          fontSize: 14,
          isDisabled: true,
        ),
      ],
    ),
  ),
  adversarial(
    'contrast/large_text_passes_at_lower_ratio',
    _rule,
    // ratio 3.5 would fail as normal text (< 4.5) but passes as large text
    // (>= 3.0); the rule must apply the size-aware threshold, not flag it.
    snap(
      node(),
      contrastSamples: [
        _sample('trap.largeok', fg: 0.0, bg: 0.125, fontSize: 30),
      ],
    ),
  ),
];
