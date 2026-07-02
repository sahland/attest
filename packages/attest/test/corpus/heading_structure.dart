import 'support.dart';

const _rule = 'attest/heading-structure';
const _wcag = '1.3.1';

TextStyleData _style({double? size, int? weight}) =>
    TextStyleData(fontSize: size, fontWeight: weight);

/// Corpus for `attest/heading-structure` (WCAG 1.3.1, heuristic): text that
/// looks like a heading (large, or bold and fairly large) but exposes no header
/// semantics. Suppressed entirely once any node on the screen is a header.
final List<CorpusCase> headingStructureCases = [
  // --- positive ---
  positive(
    'heading_structure/large_plain_title',
    _rule,
    snap(
      node(
        identifier: 'off.title',
        label: 'Welcome',
        textStyle: _style(size: 28),
      ),
    ),
    [ef(_rule, _wcag, 'off.title')],
  ),
  positive(
    'heading_structure/bold_medium_title',
    _rule,
    snap(
      node(
        identifier: 'off.section',
        label: 'Your orders',
        textStyle: _style(size: 22, weight: 700),
      ),
    ),
    [ef(_rule, _wcag, 'off.section')],
  ),
  positive(
    'heading_structure/title_nested_in_column',
    _rule,
    snap(
      node(
        children: [
          node(label: 'body', textStyle: _style(size: 14)),
          node(
            identifier: 'off.nested',
            label: 'Details',
            textStyle: _style(size: 26),
          ),
        ],
      ),
    ),
    [ef(_rule, _wcag, 'off.nested')],
  ),
  positive(
    'heading_structure/two_unmarked_headings',
    _rule,
    snap(
      node(
        children: [
          node(
            identifier: 'off.h1',
            label: 'Section one',
            textStyle: _style(size: 26),
          ),
          node(
            identifier: 'off.h2',
            label: 'Section two',
            textStyle: _style(size: 26),
          ),
        ],
      ),
    ),
    [ef(_rule, _wcag, 'off.h1'), ef(_rule, _wcag, 'off.h2')],
  ),

  // --- clean ---
  clean(
    'heading_structure/small_body_text',
    _rule,
    snap(
      node(
        identifier: 'ok.body',
        label: 'paragraph',
        textStyle: _style(size: 14),
      ),
    ),
  ),
  clean(
    'heading_structure/header_marked',
    _rule,
    snap(
      node(
        children: [
          node(
            identifier: 'ok.header',
            label: 'Title',
            flags: {isHeader},
            textStyle: _style(size: 28),
          ),
        ],
      ),
    ),
  ),

  // --- adversarial ---
  adversarial(
    'heading_structure/big_title_but_headers_used',
    _rule,
    // A header exists elsewhere, so the developer clearly knows about heading
    // semantics; even an obvious big title is not flagged.
    snap(
      node(
        children: [
          node(label: 'Nav', flags: {isHeader}, textStyle: _style(size: 16)),
          node(label: 'Huge Title', textStyle: _style(size: 32)),
        ],
      ),
    ),
  ),
  adversarial(
    'heading_structure/large_text_without_style',
    _rule,
    // No style information (e.g. an image or a merged node): cannot infer a
    // heading.
    snap(node(identifier: 'trap.nostyle', label: 'Big')),
  ),
  adversarial(
    'heading_structure/bold_but_small',
    _rule,
    snap(node(label: 'chip', textStyle: _style(size: 16, weight: 700))),
  ),
];
