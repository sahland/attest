# attest

The pure-Dart core of the [**attest**](https://github.com/sahland/attest)
accessibility-compliance toolkit for Flutter: the data model, the rule engine,
the tree-walking rules, report aggregation and baseline diffing.

> **Honest framing.** Automated checks catch roughly 30–40% of accessibility
> issues. This package provides automated coverage of machine-checkable
> criteria plus a structured checklist for the rest. It does **not** certify
> "EAA compliance."

This package has no Flutter dependency. Every rule is a pure function over a
serializable `SemanticsSnapshot`, which makes rules fast and exhaustively
unit-testable. The Flutter-facing helpers (the `WidgetTester` extension and the
raster/text-scale collectors) live in
[`attest_flutter`](https://pub.dev/packages/attest_flutter).

## Measured correctness

For a compliance tool, trust is the product — so correctness is measured, not
claimed. attest ships a validation corpus of **109 hand-labelled cases**
(positive, clean, adversarial, and composite real-world screens) and computes
**precision and recall per rule** against it on every CI run.

On the current corpus every one of the twelve rules measures **precision 1.0
and recall 1.0, with zero false positives on the clean fixtures.** The metrics
gate fails the build on any regression, on any false positive on a clean case,
or if a heuristic drops below its declared precision bar. The contrast and
overflow measurement paths are additionally reference-validated (contrast
against independently computed WCAG ratios within 0.1).

This measures that the rules do exactly what they claim on known inputs and
stay honest as they change — it is **not** a claim that automated checks catch
every real-world issue. They cover the machine-checkable ~30–40%; the rest is
the structured checklist referenced above.

## Standard packs

Audits run against a versioned pack, chosen with `RuleConfig.standard`:

- `Standard.en301549_v3_2_1` (default) — WCAG 2.1 Level AA, the current EU legal
  baseline.
- `Standard.wcag22` — WCAG 2.2 Level AA, the basis for the forthcoming
  EN 301 549 v4.1.1.

A rule runs only when its cited criterion belongs to the selected pack, so
switching packs changes both the checks that run and the criteria cited. For
example `attest/target-size` (WCAG 2.5.8) is new in 2.2, so it is inactive under
the default `en301549_v3_2_1` pack and active under `wcag22`.

**Migrating to WCAG 2.2:** set `standard: Standard.wcag22`, then re-run
`attest baseline --update` — the newly active rules may add findings you will
want to review and accept.

## Supported versions

Pure Dart, **SDK ≥ 3.6**, no Flutter dependency — it runs anywhere Dart runs
(the CI gate, scripts, servers). The floor is set by the repository's
pub-workspace tooling, not by any language feature the code needs. The policy
for the toolkit as a whole: the current and the previous three stable Flutter
releases are supported, and each new stable Flutter is tracked within one
release cycle.

## API stability

Everything exported from `package:attest/attest.dart` is frozen for 1.0:
within a major version it will not break, and rule ids and standard-pack
meanings never change silently — both are treated as breaking. Two exceptions,
annotated `@experimental` and free to change in minor releases (always
changelogged):

- the validation-corpus library (`package:attest/corpus.dart`), which is young
  and will evolve with the corpus;
- `TranscriptGenerator` — the transcript's exact wording is not frozen until it
  is cross-validated against real VoiceOver/TalkBack captures.

## License

BSD-3-Clause.
