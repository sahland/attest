import 'support.dart';

const _rule = 'attest/image-alt';
const _wcag = '1.1.1';

/// Corpus for `attest/image-alt` (WCAG 1.1.1): a semantics-visible image must
/// carry a text alternative.
final List<CorpusCase> imageAltCases = [
  // --- positive ---
  positive(
    'image_alt/bare_unlabeled_image',
    _rule,
    snap(node(identifier: 'off.img', flags: {isImage})),
    [ef(_rule, _wcag, 'off.img')],
  ),
  positive(
    'image_alt/whitespace_label',
    _rule,
    // A label of only spaces is not a text alternative.
    snap(node(identifier: 'off.ws', label: '   ', flags: {isImage})),
    [ef(_rule, _wcag, 'off.ws')],
  ),
  positive(
    'image_alt/unlabeled_image_nested',
    _rule,
    snap(
      node(
        children: [
          node(identifier: 'off.nested', flags: {isImage}),
        ],
      ),
    ),
    [ef(_rule, _wcag, 'off.nested')],
  ),
  positive(
    'image_alt/one_of_two_unlabeled',
    _rule,
    // The labeled sibling stays silent; only the unlabeled image is flagged.
    snap(
      node(
        children: [
          node(label: 'Logo', flags: {isImage}),
          node(identifier: 'off.unlabeled', flags: {isImage}),
        ],
      ),
    ),
    [ef(_rule, _wcag, 'off.unlabeled')],
  ),

  // --- clean ---
  clean(
    'image_alt/labeled_image',
    _rule,
    snap(node(identifier: 'ok.img', label: 'Revenue chart', flags: {isImage})),
  ),
  clean(
    'image_alt/two_labeled_images',
    _rule,
    snap(
      node(
        children: [
          node(label: 'Logo', flags: {isImage}),
          node(label: 'Team photo', flags: {isImage}),
        ],
      ),
    ),
  ),

  // --- adversarial ---
  adversarial(
    'image_alt/interactive_image_left_to_interactive_name',
    _rule,
    // An icon button reports as an interactive image; interactive-name owns it.
    snap(
      node(
        identifier: 'trap.iconbtn',
        flags: {isImage, isButton},
        actions: {tap},
      ),
    ),
  ),
  adversarial(
    'image_alt/placeholder_label_left_to_placeholder_name',
    _rule,
    // The label is present (if generic), so image-alt is satisfied; the generic
    // "image" wording is placeholder-name's concern.
    snap(node(identifier: 'trap.imgword', label: 'image', flags: {isImage})),
  ),
];
