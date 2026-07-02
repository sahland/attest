import 'support.dart';

const _rule = 'attest/field-label';
const _wcag = '1.3.1';

/// Corpus for `attest/field-label` (WCAG 1.3.1): a form control must have a
/// programmatic label; a hint or placeholder does not count.
final List<CorpusCase> fieldLabelCases = [
  // --- positive ---
  positive(
    'field_label/unlabeled_text_field',
    _rule,
    snap(node(identifier: 'off.tf', flags: {isTextField})),
    [ef(_rule, _wcag, 'off.tf')],
  ),
  positive(
    'field_label/unlabeled_checkbox',
    _rule,
    snap(node(identifier: 'off.cb', flags: {hasCheckedState})),
    [ef(_rule, _wcag, 'off.cb')],
  ),
  positive(
    'field_label/unlabeled_switch',
    _rule,
    snap(node(identifier: 'off.sw', flags: {hasToggledState})),
    [ef(_rule, _wcag, 'off.sw')],
  ),
  positive(
    'field_label/hint_is_not_a_label',
    _rule,
    // A hint / placeholder disappears once the user types and is not announced
    // as the field's name.
    snap(node(identifier: 'off.hint', hint: 'Email', flags: {isTextField})),
    [ef(_rule, _wcag, 'off.hint')],
  ),
  positive(
    'field_label/value_is_not_a_label',
    _rule,
    snap(
      node(identifier: 'off.val', value: 'typed text', flags: {isTextField}),
    ),
    [ef(_rule, _wcag, 'off.val')],
  ),

  // --- clean ---
  clean(
    'field_label/labeled_text_field',
    _rule,
    snap(node(identifier: 'ok.tf', label: 'Email', flags: {isTextField})),
  ),
  clean(
    'field_label/labeled_checkbox',
    _rule,
    snap(node(identifier: 'ok.cb', label: 'I agree', flags: {hasCheckedState})),
  ),

  // --- adversarial ---
  adversarial(
    'field_label/button_is_not_a_form_control',
    _rule,
    // A bare button is unlabeled but is interactive-name's concern, not a field.
    snap(node(identifier: 'trap.btn', flags: {isButton}, actions: {tap})),
  ),
  adversarial(
    'field_label/image_is_not_a_form_control',
    _rule,
    snap(node(identifier: 'trap.img', flags: {isImage})),
  ),
];
