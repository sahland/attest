import 'support.dart';

const _rule = 'attest/interactive-name';
const _wcag = '4.1.2';

/// Corpus for `attest/interactive-name` (WCAG 4.1.2): an interactive element
/// must expose an accessible name.
final List<CorpusCase> interactiveNameCases = [
  // --- positive: the rule must fire ---
  positive(
    'interactive_name/unnamed_button',
    _rule,
    snap(node(identifier: 'off.button', flags: {isButton}, actions: {tap})),
    [ef(_rule, _wcag, 'off.button')],
  ),
  positive(
    'interactive_name/unnamed_link',
    _rule,
    snap(node(identifier: 'off.link', flags: {isLink}, actions: {tap})),
    [ef(_rule, _wcag, 'off.link')],
  ),
  positive(
    'interactive_name/tappable_without_role',
    _rule,
    // A bare GestureDetector: a tap action, no role, no name.
    snap(node(identifier: 'off.gesture', actions: {tap})),
    [ef(_rule, _wcag, 'off.gesture')],
  ),
  positive(
    'interactive_name/long_press_only',
    _rule,
    snap(node(identifier: 'off.longpress', actions: {longPress})),
    [ef(_rule, _wcag, 'off.longpress')],
  ),
  positive(
    'interactive_name/value_is_not_a_name',
    _rule,
    // A value ("On") is not an accessible name; the control is still unnamed.
    snap(
      node(
        identifier: 'off.valuebtn',
        value: 'On',
        flags: {isButton},
        actions: {tap},
      ),
    ),
    [ef(_rule, _wcag, 'off.valuebtn')],
  ),

  // --- clean: the rule must stay silent ---
  clean(
    'interactive_name/labeled_button',
    _rule,
    snap(
      node(
        identifier: 'ok.button',
        label: 'Pay',
        flags: {isButton},
        actions: {tap},
      ),
    ),
  ),
  clean(
    'interactive_name/tooltip_named_icon_button',
    _rule,
    // An IconButton names itself through its tooltip.
    snap(
      node(
        identifier: 'ok.icon',
        tooltip: 'Search',
        flags: {isButton},
        actions: {tap},
      ),
    ),
  ),
  clean(
    'interactive_name/labeled_link',
    _rule,
    snap(
      node(
        identifier: 'ok.link',
        label: 'Home',
        flags: {isLink},
        actions: {tap},
      ),
    ),
  ),

  // --- adversarial: known false-positive traps ---
  adversarial(
    'interactive_name/named_by_child_text',
    _rule,
    // ElevatedButton(child: Text('Pay')): the name comes from a child node.
    snap(
      node(
        identifier: 'trap.childtext',
        flags: {isButton},
        actions: {tap},
        children: [node(label: 'Pay')],
      ),
    ),
  ),
  adversarial(
    'interactive_name/text_field_left_to_field_label',
    _rule,
    // A text field is interactive but is the field-label rule's responsibility;
    // interactive-name must not double-report it.
    snap(
      node(
        identifier: 'trap.textfield',
        flags: {isTextField},
        actions: {tap},
      ),
    ),
  ),
  adversarial(
    'interactive_name/checkbox_left_to_field_label',
    _rule,
    // Likewise a checkable control is owned by field-label, not interactive-name.
    snap(
      node(
        identifier: 'trap.checkbox',
        flags: {hasCheckedState},
        actions: {tap},
      ),
    ),
  ),
];
