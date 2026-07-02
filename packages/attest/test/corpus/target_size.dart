import 'support.dart';

const _rule = 'attest/target-size';
const _wcag = '2.5.8';

// WCAG 2.5.8 is new in 2.2, so it only runs under the wcag22 pack; the default
// en301549_v3_2_1 pack predates it and the rule would be filtered out.
const _pack = Standard.wcag22;

/// Corpus for `attest/target-size` (WCAG 2.5.8): a touch target must meet the
/// minimum size (48 logical px by default).
final List<CorpusCase> targetSizeCases = [
  // --- positive ---
  positive(
    'target_size/tiny_icon_button',
    _rule,
    snap(
      node(
        identifier: 'off.tiny',
        label: 'Close',
        flags: {isButton},
        actions: {tap},
        bounds: rect(0, 0, 24, 24),
      ),
    ),
    [ef(_rule, _wcag, 'off.tiny')],
    standard: _pack,
  ),
  positive(
    'target_size/short_button',
    _rule,
    snap(
      node(
        identifier: 'off.short',
        label: 'OK',
        flags: {isButton},
        actions: {tap},
        bounds: rect(0, 0, 100, 20),
      ),
    ),
    [ef(_rule, _wcag, 'off.short')],
    standard: _pack,
  ),
  positive(
    'target_size/small_gesture_target',
    _rule,
    snap(
      node(
        identifier: 'off.gesture',
        label: 'Tap',
        actions: {tap},
        bounds: rect(0, 0, 30, 30),
      ),
    ),
    [ef(_rule, _wcag, 'off.gesture')],
    standard: _pack,
  ),
  positive(
    'target_size/narrow_button',
    _rule,
    snap(
      node(
        identifier: 'off.narrow',
        label: 'Go',
        flags: {isButton},
        actions: {tap},
        bounds: rect(0, 0, 40, 60),
      ),
    ),
    [ef(_rule, _wcag, 'off.narrow')],
    standard: _pack,
  ),

  // --- clean ---
  clean(
    'target_size/exactly_minimum',
    _rule,
    snap(
      node(
        identifier: 'ok.min',
        label: 'Close',
        flags: {isButton},
        actions: {tap},
        bounds: rect(0, 0, 48, 48),
      ),
    ),
    standard: _pack,
  ),
  clean(
    'target_size/comfortably_large',
    _rule,
    snap(
      node(
        identifier: 'ok.large',
        label: 'Continue',
        flags: {isButton},
        actions: {tap},
        bounds: rect(0, 0, 120, 56),
      ),
    ),
    standard: _pack,
  ),

  // --- adversarial ---
  adversarial(
    'target_size/small_inline_link_exempt',
    _rule,
    // WCAG 2.5.8 exempts inline links.
    snap(
      node(
        identifier: 'trap.link',
        label: 'terms',
        flags: {isLink},
        actions: {tap},
        bounds: rect(0, 0, 20, 20),
      ),
    ),
    standard: _pack,
  ),
  adversarial(
    'target_size/hidden_target',
    _rule,
    // A hidden target is not presented to the user.
    snap(
      node(
        identifier: 'trap.hidden',
        flags: {isHidden},
        actions: {tap},
        bounds: rect(0, 0, 10, 10),
      ),
    ),
    standard: _pack,
  ),
  adversarial(
    'target_size/zero_bounds_unmeasured',
    _rule,
    // A zero-size rect means the target was not laid out / is offscreen.
    snap(
      node(
        identifier: 'trap.zero',
        label: 'x',
        actions: {tap},
        bounds: rect(0, 0, 0, 0),
      ),
    ),
    standard: _pack,
  ),
];
