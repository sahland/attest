import 'support.dart';

const _rule = 'attest/generic-link-text';
const _wcag = '2.4.4';

/// Corpus for `attest/generic-link-text` (WCAG 2.4.4, heuristic): a link's name
/// must describe its destination, not be a generic phrase.
final List<CorpusCase> genericLinkTextCases = [
  // --- positive ---
  positive(
    'generic_link_text/click_here',
    _rule,
    snap(
      node(
        identifier: 'off.click',
        label: 'Click here',
        flags: {isLink},
        actions: {tap},
      ),
    ),
    [ef(_rule, _wcag, 'off.click')],
  ),
  positive(
    'generic_link_text/read_more',
    _rule,
    snap(
      node(
        identifier: 'off.read',
        label: 'Read more',
        flags: {isLink},
        actions: {tap},
      ),
    ),
    [ef(_rule, _wcag, 'off.read')],
  ),
  positive(
    'generic_link_text/bare_here',
    _rule,
    snap(
      node(
        identifier: 'off.here',
        label: 'here',
        flags: {isLink},
        actions: {tap},
      ),
    ),
    [ef(_rule, _wcag, 'off.here')],
  ),
  positive(
    'generic_link_text/learn_more_mixed_case',
    _rule,
    snap(
      node(
        identifier: 'off.learn',
        label: 'Learn More',
        flags: {isLink},
        actions: {tap},
      ),
    ),
    [ef(_rule, _wcag, 'off.learn')],
  ),

  // --- clean ---
  clean(
    'generic_link_text/descriptive_link',
    _rule,
    snap(
      node(
        identifier: 'ok.report',
        label: 'Read the 2026 annual report',
        flags: {isLink},
        actions: {tap},
      ),
    ),
  ),
  clean(
    'generic_link_text/named_destination',
    _rule,
    snap(
      node(
        identifier: 'ok.invoice',
        label: 'Download invoice PDF',
        flags: {isLink},
        actions: {tap},
      ),
    ),
  ),

  // --- adversarial ---
  adversarial(
    'generic_link_text/generic_on_button_not_link',
    _rule,
    // The rule targets links; a button labelled "Read more" is out of scope.
    snap(
      node(
        identifier: 'trap.btn',
        label: 'Read more',
        flags: {isButton},
        actions: {tap},
      ),
    ),
  ),
  adversarial(
    'generic_link_text/generic_static_text',
    _rule,
    // Plain text, not a link.
    snap(node(identifier: 'trap.text', label: 'more')),
  ),
  adversarial(
    'generic_link_text/unnamed_link',
    _rule,
    // An unnamed link is interactive-name's concern, not this rule's.
    snap(node(identifier: 'trap.unnamed', flags: {isLink}, actions: {tap})),
  ),
];
