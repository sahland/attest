import 'support.dart';

const _rule = 'attest/placeholder-name';
const _wcag = '2.4.6';

/// Corpus for `attest/placeholder-name` (WCAG 2.4.6): a nameable element's
/// accessible name must not be a generic placeholder token.
final List<CorpusCase> placeholderNameCases = [
  // --- positive ---
  positive(
    'placeholder_name/button_named_button',
    _rule,
    snap(
      node(
        identifier: 'off.btn',
        label: 'Button',
        flags: {isButton},
        actions: {tap},
      ),
    ),
    [ef(_rule, _wcag, 'off.btn')],
  ),
  positive(
    'placeholder_name/image_named_image',
    _rule,
    snap(node(identifier: 'off.img', label: 'Image', flags: {isImage})),
    [ef(_rule, _wcag, 'off.img')],
  ),
  positive(
    'placeholder_name/header_named_untitled',
    _rule,
    snap(node(identifier: 'off.hdr', label: 'Untitled', flags: {isHeader})),
    [ef(_rule, _wcag, 'off.hdr')],
  ),
  positive(
    'placeholder_name/field_named_text',
    _rule,
    // The field has a label, so field-label is satisfied, but "Text" is generic.
    snap(node(identifier: 'off.tf', label: 'Text', flags: {isTextField})),
    [ef(_rule, _wcag, 'off.tf')],
  ),
  positive(
    'placeholder_name/icon_button_named_icon',
    _rule,
    snap(
      node(
        identifier: 'off.icon',
        label: 'Icon',
        flags: {isButton},
        actions: {tap},
      ),
    ),
    [ef(_rule, _wcag, 'off.icon')],
  ),

  // --- clean ---
  clean(
    'placeholder_name/meaningful_button',
    _rule,
    snap(
      node(
        identifier: 'ok.btn',
        label: 'Checkout',
        flags: {isButton},
        actions: {tap},
      ),
    ),
  ),
  clean(
    'placeholder_name/meaningful_image',
    _rule,
    snap(node(identifier: 'ok.img', label: 'Team photo', flags: {isImage})),
  ),

  // --- adversarial ---
  adversarial(
    'placeholder_name/plain_text_is_not_nameable',
    _rule,
    // A Text('Button') widget is not an interactive/image/field/header node, so
    // its content is not an accessible name to police.
    snap(node(identifier: 'trap.text', label: 'Button')),
  ),
  adversarial(
    'placeholder_name/label_only_contains_token',
    _rule,
    // "Submit button" is specific; only a label that *equals* a denylist token
    // is a placeholder.
    snap(
      node(
        identifier: 'trap.superset',
        label: 'Submit button',
        flags: {isButton},
        actions: {tap},
      ),
    ),
  ),
];
