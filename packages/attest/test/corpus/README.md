# Validation corpus

Labelled accessibility cases with hand-authored ground truth. The
precision/recall harness (see `metrics_test.dart`) runs every case, matches
what the engine finds against what a human said it should find, and computes
per-rule precision, recall and false-positive rate. This is how `attest` proves
it is correct rather than claiming it — see `context/Stage2/10_QUALITY_AND_CORRECTNESS.md`.

## Layout

```
corpus/
  <rule>/                 # one directory per rule, e.g. interactive_name/
    <case>.dart           # one file per case; exposes a `final CorpusCase`
  all_cases.dart          # explicit registry of every case (no reflection)
  README.md               # this file
```

A case file is small and self-contained:

```dart
import 'package:attest/attest.dart';
import 'package:attest/corpus.dart';
import '../../support/fixtures.dart';

final CorpusCase myCase = CorpusCase(
  id: 'interactive_name/unnamed_button',
  category: CorpusCategory.positive,
  standard: Standard.en301549_v3_2_1,
  ruleUnderTest: 'attest/interactive-name',
  build: () => snap(node(identifier: 'offender.x', flags: {isButton}, actions: {tap})),
  expected: const [
    ExpectedFinding(ruleId: 'attest/interactive-name', wcag: '4.1.2', identifier: 'offender.x'),
  ],
);
```

Then add `myCase` to `corpusCases` in `all_cases.dart`.

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
