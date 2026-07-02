import 'support.dart';

const _rule = 'attest/focus-trap';
const _wcag = '2.1.1';

/// Corpus for `attest/focus-trap` (WCAG 2.1.1): an element that is tappable but
/// hidden from assistive technology is unreachable by screen reader / keyboard.
final List<CorpusCase> focusTrapCases = [
  // --- positive ---
  positive(
    'focus_trap/hidden_button',
    _rule,
    snap(
      node(identifier: 'off.hbtn', flags: {isButton, isHidden}, actions: {tap}),
    ),
    [ef(_rule, _wcag, 'off.hbtn')],
  ),
  positive(
    'focus_trap/hidden_tappable',
    _rule,
    snap(node(identifier: 'off.htap', flags: {isHidden}, actions: {tap})),
    [ef(_rule, _wcag, 'off.htap')],
  ),
  positive(
    'focus_trap/hidden_link',
    _rule,
    snap(
      node(identifier: 'off.hlink', flags: {isLink, isHidden}, actions: {tap}),
    ),
    [ef(_rule, _wcag, 'off.hlink')],
  ),
  positive(
    'focus_trap/hidden_long_press',
    _rule,
    snap(
      node(identifier: 'off.hlong', flags: {isHidden}, actions: {longPress}),
    ),
    [ef(_rule, _wcag, 'off.hlong')],
  ),

  // --- clean ---
  clean(
    'focus_trap/visible_button',
    _rule,
    snap(
      node(
        identifier: 'ok.btn',
        label: 'Pay',
        flags: {isButton},
        actions: {tap},
      ),
    ),
  ),
  clean(
    'focus_trap/hidden_static_text',
    _rule,
    // Hidden but not interactive: nothing to reach.
    snap(node(identifier: 'ok.text', label: 'decorative', flags: {isHidden})),
  ),

  // --- adversarial ---
  adversarial(
    'focus_trap/hidden_decorative_image',
    _rule,
    snap(
      node(identifier: 'trap.himg', label: 'decor', flags: {isHidden, isImage}),
    ),
  ),
  adversarial(
    'focus_trap/hidden_scrollable_not_interactive',
    _rule,
    // A hidden scroll area is not an interactive control the rule targets.
    snap(
      node(
        identifier: 'trap.scroll',
        flags: {isHidden},
        actions: {SemanticsActionData.scrollUp},
      ),
    ),
  ),
];
