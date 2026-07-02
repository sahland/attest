# Validation corpus

Labelled accessibility cases with hand-authored ground truth. The
precision/recall harness (see `metrics_test.dart`) runs every case, matches
what the engine finds against what a human said it should find, and computes
per-rule precision, recall and false-positive rate. This is how `attest` proves
it is correct rather than claiming it — see `context/Stage2/10_QUALITY_AND_CORRECTNESS.md`.

## Layout

```
corpus/
  <rule>.dart             # one file per rule; exposes a `List<CorpusCase>`
  all_cases.dart          # explicit registry aggregating every rule's list
  support.dart            # concise case builders (positive/clean/adversarial…)
  README.md               # this file
```

A rule's file uses the builders in `support.dart`, which re-export the fixture
primitives (`node`, `snap`, the flag/action aliases). Cases read like the trees
they describe:

```dart
import 'support.dart';

const _rule = 'attest/interactive-name';
const _wcag = '4.1.2';

final List<CorpusCase> interactiveNameCases = [
  positive(
    'interactive_name/unnamed_button',
    _rule,
    snap(node(identifier: 'off.button', flags: {isButton}, actions: {tap})),
    [ef(_rule, _wcag, 'off.button')],
  ),
  clean('interactive_name/labeled_button', _rule,
      snap(node(identifier: 'ok.button', label: 'Pay', flags: {isButton}, actions: {tap}))),
  adversarial('interactive_name/named_by_child_text', _rule,
      snap(node(identifier: 'trap.x', flags: {isButton}, actions: {tap}, children: [node(label: 'Pay')]))),
];
```

Then spread the list into `corpusCases` in `all_cases.dart`.

## The rules of authoring a case

- **Anchor on `identifier`, not location.** Tag the intended-offending node with
  `node(identifier: 'offender.<thing>')` (or `Semantics(identifier: ...)` in a
  widget fixture) and reference that same id in every `ExpectedFinding`. The
  harness resolves a finding to its node's identifier, or the nearest ancestor's.
- **Categories:**
  - `positive` — exactly one known violation of `ruleUnderTest`; list it in
    `expected`.
  - `clean` — correct screen; `expected` empty; the rule must stay silent.
  - `adversarial` — a known false-positive trap for the rule; `expected` empty.
  - `realWorld` — a composite screen with **all** rules enabled; leave
    `ruleUnderTest` null and label every expected finding across every rule.
- **Isolation.** Every category except `realWorld` sets `ruleUnderTest`; the
  harness scores only that rule's findings, so unrelated rules cannot pollute the
  measurement.
- **Every bug becomes a case.** When a real false positive or missed violation is
  found, add an adversarial or positive case that fails before the fix and passes
  after. That is how correctness compounds.
