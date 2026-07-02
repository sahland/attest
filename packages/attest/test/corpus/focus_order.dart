import 'support.dart';

const _rule = 'attest/focus-order';
const _wcag = '2.4.3';

/// Corpus for `attest/focus-order` (WCAG 2.4.3, heuristic): traversal should not
/// jump upward. The rule flags a child reached right after one positioned
/// entirely below it.
final List<CorpusCase> focusOrderCases = [
  // --- positive (flags the later, higher element) ---
  positive(
    'focus_order/second_child_above_first',
    _rule,
    snap(
      node(
        children: [
          node(label: 'lower', bounds: rect(0, 200, 100, 48)),
          node(
            identifier: 'off.b',
            label: 'upper',
            bounds: rect(0, 0, 100, 48),
          ),
        ],
      ),
    ),
    [ef(_rule, _wcag, 'off.b')],
  ),
  positive(
    'focus_order/inverted_pair_far_apart',
    _rule,
    snap(
      node(
        children: [
          node(label: 'bottom', bounds: rect(0, 300, 80, 40)),
          node(
            identifier: 'off.b2',
            label: 'top',
            bounds: rect(0, 100, 80, 40),
          ),
        ],
      ),
    ),
    [ef(_rule, _wcag, 'off.b2')],
  ),
  positive(
    'focus_order/inversion_nested',
    _rule,
    snap(
      node(
        children: [
          node(
            children: [
              node(label: 'lower', bounds: rect(0, 220, 100, 48)),
              node(
                identifier: 'off.nested',
                label: 'upper',
                bounds: rect(0, 20, 100, 48),
              ),
            ],
          ),
        ],
      ),
    ),
    [ef(_rule, _wcag, 'off.nested')],
  ),
  positive(
    'focus_order/third_child_jumps_up',
    _rule,
    // A→B read downward, then C sits above B: traversal jumps up at C.
    snap(
      node(
        children: [
          node(label: 'a', bounds: rect(0, 0, 100, 48)),
          node(label: 'b', bounds: rect(0, 200, 100, 48)),
          node(identifier: 'off.c', label: 'c', bounds: rect(0, 100, 100, 48)),
        ],
      ),
    ),
    [ef(_rule, _wcag, 'off.c')],
  ),

  // --- clean ---
  clean(
    'focus_order/top_to_bottom',
    _rule,
    snap(
      node(
        children: [
          node(label: 'a', bounds: rect(0, 0, 100, 48)),
          node(label: 'b', bounds: rect(0, 100, 100, 48)),
        ],
      ),
    ),
  ),
  clean(
    'focus_order/side_by_side_row',
    _rule,
    snap(
      node(
        children: [
          node(label: 'a', bounds: rect(0, 0, 100, 48)),
          node(label: 'b', bounds: rect(120, 0, 100, 48)),
        ],
      ),
    ),
  ),

  // --- adversarial ---
  adversarial(
    'focus_order/partial_overlap_not_inverted',
    _rule,
    // The second element starts lower and overlaps the first; it does not sit
    // entirely above it, so this is not an inversion.
    snap(
      node(
        children: [
          node(label: 'a', bounds: rect(0, 0, 100, 60)),
          node(label: 'b', bounds: rect(0, 40, 100, 60)),
        ],
      ),
    ),
  ),
  adversarial(
    'focus_order/empty_bounds_skipped',
    _rule,
    // An unmeasured (zero-size) node cannot be compared and must not trip it.
    snap(
      node(
        children: [
          node(label: 'a', bounds: rect(0, 0, 0, 0)),
          node(label: 'b', bounds: rect(0, 0, 100, 48)),
        ],
      ),
    ),
  ),
  adversarial(
    'focus_order/horizontal_order_not_flagged',
    _rule,
    // Reading right-to-left within a row is not a vertical inversion; the rule
    // must not flag it (that is the RTL false-positive trap).
    snap(
      node(
        children: [
          node(label: 'right', bounds: rect(120, 0, 100, 48)),
          node(label: 'left', bounds: rect(0, 0, 100, 48)),
        ],
      ),
    ),
  ),
];
