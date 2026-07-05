import 'support.dart';

const _rule = 'attest/adjustable-value';
const _wcag = '4.1.2';

/// Corpus for `attest/adjustable-value` (WCAG 4.1.2): an adjustable control
/// (slider, stepper) must expose its current value.
final List<CorpusCase> adjustableValueCases = [
  // --- positive ---
  positive(
    'adjustable_value/slider_no_value',
    _rule,
    snap(node(identifier: 'off.slider', actions: {increase, decrease})),
    [ef(_rule, _wcag, 'off.slider')],
  ),
  positive(
    'adjustable_value/increase_only',
    _rule,
    snap(node(identifier: 'off.inc', actions: {increase})),
    [ef(_rule, _wcag, 'off.inc')],
  ),
  positive(
    'adjustable_value/decrease_only',
    _rule,
    snap(node(identifier: 'off.dec', actions: {decrease})),
    [ef(_rule, _wcag, 'off.dec')],
  ),
  positive(
    'adjustable_value/labeled_but_no_value',
    _rule,
    // A label ("Volume") is not the value; the control is still unreadable.
    snap(
      node(
        identifier: 'off.labeled',
        label: 'Volume',
        actions: {increase, decrease},
      ),
    ),
    [ef(_rule, _wcag, 'off.labeled')],
  ),
  positive(
    'adjustable_value/whitespace_value',
    _rule,
    snap(
      node(
        identifier: 'off.ws',
        value: '   ',
        actions: {increase, decrease},
      ),
    ),
    [ef(_rule, _wcag, 'off.ws')],
  ),

  // --- clean ---
  clean(
    'adjustable_value/slider_with_value',
    _rule,
    snap(
      node(
        identifier: 'ok.slider',
        value: '50%',
        actions: {increase, decrease},
      ),
    ),
  ),
  clean(
    'adjustable_value/value_and_label',
    _rule,
    snap(
      node(
        identifier: 'ok.both',
        label: 'Volume',
        value: '7 of 10',
        actions: {increase, decrease},
      ),
    ),
  ),

  // --- adversarial ---
  adversarial(
    'adjustable_value/button_is_not_adjustable',
    _rule,
    // A tap-only button is not an adjustable control.
    snap(node(identifier: 'trap.btn', flags: {isButton}, actions: {tap})),
  ),
  adversarial(
    'adjustable_value/text_field_is_not_adjustable',
    _rule,
    // A text field has a value but no increase/decrease; not this rule's target.
    snap(
      node(identifier: 'trap.field', value: 'typed', flags: {isTextField}),
    ),
  ),
  adversarial(
    'adjustable_value/scrollable_is_not_adjustable',
    _rule,
    // Scrolling is not adjusting a value.
    snap(node(identifier: 'trap.scroll', actions: {scrollUp, scrollDown})),
  ),
];
