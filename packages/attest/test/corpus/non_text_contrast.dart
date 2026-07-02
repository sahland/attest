import 'support.dart';

const _rule = 'attest/non-text-contrast';
const _wcag = '1.4.11';

final _bounds = rect(0, 0, 24, 24);

ContrastSample _icon(
  String identifier, {
  required double fg,
  required double bg,
  bool isDisabled = false,
  bool isNonText = true,
}) =>
    ContrastSample(
      identifier: identifier,
      label: identifier,
      foregroundLuminance: fg,
      backgroundLuminance: bg,
      bounds: _bounds,
      isDisabled: isDisabled,
      isNonText: isNonText,
    );

/// Corpus for `attest/non-text-contrast` (WCAG 1.4.11): icons and other
/// non-text glyphs must contrast at least 3:1 against their background.
final List<CorpusCase> nonTextContrastCases = [
  // --- positive ---
  positive(
    'non_text_contrast/very_low_icon',
    _rule,
    // ratio 2.0.
    snap(node(), contrastSamples: [_icon('off.icon', fg: 0.0, bg: 0.05)]),
    [ef(_rule, _wcag, 'off.icon')],
  ),
  positive(
    'non_text_contrast/pale_grey_icon',
    _rule,
    // ratio ~1.6.
    snap(node(), contrastSamples: [_icon('off.pale', fg: 0.5, bg: 0.9)]),
    [ef(_rule, _wcag, 'off.pale')],
  ),
  positive(
    'non_text_contrast/borderline_icon',
    _rule,
    // ratio 2.9 -> warning, still a finding.
    snap(
      node(),
      contrastSamples: [_icon('off.borderline', fg: 0.0, bg: 0.095)],
    ),
    [ef(_rule, _wcag, 'off.borderline')],
  ),
  positive(
    'non_text_contrast/one_of_two_icons',
    _rule,
    // Only the low-contrast icon is flagged; the strong one stays silent.
    snap(
      node(),
      contrastSamples: [
        _icon('ok.strong', fg: 0.0, bg: 0.6),
        _icon('off.weak', fg: 0.0, bg: 0.05),
      ],
    ),
    [ef(_rule, _wcag, 'off.weak')],
  ),

  // --- clean ---
  clean(
    'non_text_contrast/exactly_three_to_one',
    _rule,
    // ratio exactly 3.0 meets the minimum.
    snap(node(), contrastSamples: [_icon('ok.min', fg: 0.0, bg: 0.1)]),
  ),
  clean(
    'non_text_contrast/strong_icon',
    _rule,
    // ratio ~13.
    snap(node(), contrastSamples: [_icon('ok.strong', fg: 0.0, bg: 0.6)]),
  ),

  // --- adversarial ---
  adversarial(
    'non_text_contrast/icon_passes_below_text_threshold',
    _rule,
    // ratio 3.5: fails the 4.5:1 text minimum but is a valid non-text ratio.
    // The rule must NOT flag it (this is the false positive the split fixes).
    snap(node(), contrastSamples: [_icon('trap.iconok', fg: 0.30, bg: 0.05)]),
  ),
  adversarial(
    'non_text_contrast/disabled_icon_exempt',
    _rule,
    snap(
      node(),
      contrastSamples: [
        _icon('trap.disabled', fg: 0.0, bg: 0.02, isDisabled: true),
      ],
    ),
  ),
  adversarial(
    'non_text_contrast/text_sample_left_to_contrast',
    _rule,
    // A low-contrast *text* sample is the contrast rule's concern, not this one.
    snap(
      node(),
      contrastSamples: [
        _icon('trap.text', fg: 0.0, bg: 0.05, isNonText: false),
      ],
    ),
  ),
];
