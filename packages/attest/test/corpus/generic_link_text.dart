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
  positive(
    // Trailing ellipsis is the single most common real-world form of generic
    // link text; it must not slip through on a literal-string compare.
    'generic_link_text/read_more_ellipsis',
    _rule,
    snap(
      node(
        identifier: 'off.ellipsis',
        label: 'Read more…',
        flags: {isLink},
        actions: {tap},
      ),
    ),
    [ef(_rule, _wcag, 'off.ellipsis')],
  ),
  positive(
    'generic_link_text/more_arrow',
    _rule,
    snap(
      node(
        identifier: 'off.arrow',
        label: 'More ›',
        flags: {isLink},
        actions: {tap},
      ),
    ),
    [ef(_rule, _wcag, 'off.arrow')],
  ),
  positive(
    'generic_link_text/learn_more_bang',
    _rule,
    snap(
      node(
        identifier: 'off.bang',
        label: 'Learn more!',
        flags: {isLink},
        actions: {tap},
      ),
    ),
    [ef(_rule, _wcag, 'off.bang')],
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
  adversarial(
    // A generic phrase as a *prefix* of descriptive text is fine — the purpose
    // is clear from the whole name. This pins that we match the whole label,
    // never a substring: a `contains` implementation would false-positive here.
    'generic_link_text/generic_prefix_descriptive',
    _rule,
    snap(
      node(
        identifier: 'trap.prefix',
        label: 'Read more about the 2026 pricing changes',
        flags: {isLink},
        actions: {tap},
      ),
    ),
  ),
  adversarial(
    // A generic word embedded mid-label is still descriptive as a whole.
    'generic_link_text/generic_word_embedded',
    _rule,
    snap(
      node(
        identifier: 'trap.embedded',
        label: 'Learn more about accessibility at work',
        flags: {isLink},
        actions: {tap},
      ),
    ),
  ),
  adversarial(
    // Edge-decoration stripping must not reach inside the label and collapse a
    // real word onto a generic phrase: "more" survives as one word among many.
    'generic_link_text/decoration_only_at_edges',
    _rule,
    snap(
      node(
        identifier: 'trap.inner',
        label: 'See our latest & greatest — read the report',
        flags: {isLink},
        actions: {tap},
      ),
    ),
  ),
];
