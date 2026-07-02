import 'support.dart';

const _rule = 'attest/ambiguous-name';
const _wcag = '2.4.6';

/// Corpus for `attest/ambiguous-name` (WCAG 2.4.6, heuristic): interactive
/// elements on one screen should not share an identical accessible name. The
/// rule flags every member of a duplicate group.
final List<CorpusCase> ambiguousNameCases = [
  // --- positive (fires on every node in the group) ---
  positive(
    'ambiguous_name/two_delete_buttons',
    _rule,
    snap(
      node(
        children: [
          node(
            identifier: 'off.del1',
            label: 'Delete',
            flags: {isButton},
            actions: {tap},
          ),
          node(
            identifier: 'off.del2',
            label: 'Delete',
            flags: {isButton},
            actions: {tap},
          ),
        ],
      ),
    ),
    [ef(_rule, _wcag, 'off.del1'), ef(_rule, _wcag, 'off.del2')],
  ),
  positive(
    'ambiguous_name/three_edit_links',
    _rule,
    snap(
      node(
        children: [
          node(
            identifier: 'off.e1',
            label: 'Edit',
            flags: {isLink},
            actions: {tap},
          ),
          node(
            identifier: 'off.e2',
            label: 'Edit',
            flags: {isLink},
            actions: {tap},
          ),
          node(
            identifier: 'off.e3',
            label: 'Edit',
            flags: {isLink},
            actions: {tap},
          ),
        ],
      ),
    ),
    [
      ef(_rule, _wcag, 'off.e1'),
      ef(_rule, _wcag, 'off.e2'),
      ef(_rule, _wcag, 'off.e3'),
    ],
  ),
  positive(
    'ambiguous_name/case_insensitive_duplicate',
    _rule,
    snap(
      node(
        children: [
          node(
            identifier: 'off.s1',
            label: 'Save',
            flags: {isButton},
            actions: {tap},
          ),
          node(
            identifier: 'off.s2',
            label: 'save',
            flags: {isButton},
            actions: {tap},
          ),
        ],
      ),
    ),
    [ef(_rule, _wcag, 'off.s1'), ef(_rule, _wcag, 'off.s2')],
  ),
  positive(
    'ambiguous_name/duplicate_across_roles',
    _rule,
    snap(
      node(
        children: [
          node(
            identifier: 'off.o1',
            label: 'Open',
            flags: {isButton},
            actions: {tap},
          ),
          node(
            identifier: 'off.o2',
            label: 'Open',
            flags: {isLink},
            actions: {tap},
          ),
        ],
      ),
    ),
    [ef(_rule, _wcag, 'off.o1'), ef(_rule, _wcag, 'off.o2')],
  ),

  // --- clean ---
  clean(
    'ambiguous_name/distinct_labels',
    _rule,
    snap(
      node(
        children: [
          node(
            identifier: 'ok.save',
            label: 'Save',
            flags: {isButton},
            actions: {tap},
          ),
          node(
            identifier: 'ok.cancel',
            label: 'Cancel',
            flags: {isButton},
            actions: {tap},
          ),
        ],
      ),
    ),
  ),
  clean(
    'ambiguous_name/single_button',
    _rule,
    snap(
      node(
        identifier: 'ok.single',
        label: 'Delete',
        flags: {isButton},
        actions: {tap},
      ),
    ),
  ),

  // --- adversarial ---
  adversarial(
    'ambiguous_name/duplicate_static_text',
    _rule,
    // Two "Total" labels that are not interactive are not ambiguous controls.
    snap(
      node(
        children: [
          node(identifier: 'trap.t1', label: 'Total'),
          node(identifier: 'trap.t2', label: 'Total'),
        ],
      ),
    ),
  ),
  adversarial(
    'ambiguous_name/one_interactive_one_static',
    _rule,
    // Only one of the two same-named nodes is interactive, so there is no group.
    snap(
      node(
        children: [
          node(
            identifier: 'trap.btn',
            label: 'Delete',
            flags: {isButton},
            actions: {tap},
          ),
          node(identifier: 'trap.caption', label: 'Delete'),
        ],
      ),
    ),
  ),
];
