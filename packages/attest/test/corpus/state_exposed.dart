import 'support.dart';

const _rule = 'attest/state-exposed';
const _wcag = '4.1.2';

/// Corpus for `attest/state-exposed` (WCAG 4.1.2, heuristic): a group of custom
/// tappable controls that never surface selected/toggled state. The rule flags
/// every member of such a group.
final List<CorpusCase> stateExposedCases = [
  // --- positive (fires on every member of the group) ---
  positive(
    'state_exposed/two_custom_tabs',
    _rule,
    snap(
      node(
        children: [
          node(identifier: 'off.t1', actions: {tap}),
          node(identifier: 'off.t2', actions: {tap}),
        ],
      ),
    ),
    [ef(_rule, _wcag, 'off.t1'), ef(_rule, _wcag, 'off.t2')],
  ),
  positive(
    'state_exposed/three_custom_chips',
    _rule,
    snap(
      node(
        children: [
          node(identifier: 'off.c1', label: 'All', actions: {tap}),
          node(identifier: 'off.c2', label: 'Unread', actions: {tap}),
          node(identifier: 'off.c3', label: 'Starred', actions: {tap}),
        ],
      ),
    ),
    [
      ef(_rule, _wcag, 'off.c1'),
      ef(_rule, _wcag, 'off.c2'),
      ef(_rule, _wcag, 'off.c3'),
    ],
  ),
  positive(
    'state_exposed/value_is_not_state',
    _rule,
    // A value ("On") does not expose selected/toggled state.
    snap(
      node(
        children: [
          node(identifier: 'off.v1', value: 'On', actions: {tap}),
          node(identifier: 'off.v2', actions: {tap}),
        ],
      ),
    ),
    [ef(_rule, _wcag, 'off.v1'), ef(_rule, _wcag, 'off.v2')],
  ),
  positive(
    'state_exposed/two_custom_segments',
    _rule,
    snap(
      node(
        children: [
          node(identifier: 'off.d', label: 'Day', actions: {tap}),
          node(identifier: 'off.w', label: 'Week', actions: {tap}),
        ],
      ),
    ),
    [ef(_rule, _wcag, 'off.d'), ef(_rule, _wcag, 'off.w')],
  ),

  // --- clean ---
  clean(
    'state_exposed/group_exposes_selected_state',
    _rule,
    // One sibling already exposes state, so the developer surfaced it.
    snap(
      node(
        children: [
          node(identifier: 'ok.sel', actions: {tap}, flags: {isSelected}),
          node(identifier: 'ok.unsel', actions: {tap}),
        ],
      ),
    ),
  ),
  clean(
    'state_exposed/single_custom_tappable',
    _rule,
    // A lone custom tappable is not a group of selectable controls.
    snap(
      node(
        children: [
          node(identifier: 'ok.one', actions: {tap}),
        ],
      ),
    ),
  ),

  // --- adversarial ---
  adversarial(
    'state_exposed/real_buttons_are_not_custom',
    _rule,
    snap(
      node(
        children: [
          node(
            identifier: 'trap.b1',
            label: 'A',
            flags: {isButton},
            actions: {tap},
          ),
          node(
            identifier: 'trap.b2',
            label: 'B',
            flags: {isButton},
            actions: {tap},
          ),
        ],
      ),
    ),
  ),
  adversarial(
    'state_exposed/links_are_not_custom',
    _rule,
    snap(
      node(
        children: [
          node(
            identifier: 'trap.l1',
            label: 'A',
            flags: {isLink},
            actions: {tap},
          ),
          node(
            identifier: 'trap.l2',
            label: 'B',
            flags: {isLink},
            actions: {tap},
          ),
        ],
      ),
    ),
  ),
];
