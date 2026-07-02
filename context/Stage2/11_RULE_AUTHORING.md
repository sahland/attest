# 11 — Rule Authoring & the public Rule API

A rule set that only its original author can extend will never reach world-standard coverage. This document defines the **public Rule API** and the contract every rule must satisfy, so that contributors — and future maintainers — can add rules safely without deep knowledge of the engine internals.

## The Rule contract

A rule is a pure function over a `SemanticsSnapshot`. It never touches live Flutter types, never holds mutable state, and is deterministic given the same snapshot and context.

```dart
abstract interface class Rule {
  /// Stable, namespaced identifier: 'attest/<kebab-case>'. Never changes once shipped.
  String get id;

  /// The success criterion this rule enforces. MANDATORY — no rule without one.
  Criterion get criterion;

  Severity get defaultSeverity;
  Confidence get confidence; // deterministic | heuristic

  /// Which standard packs this rule belongs to (e.g. wcag21_aa, wcag22, en301549_v3_2_1).
  Set<StandardPack> get packs;

  /// Pure evaluation: inspect the snapshot, yield zero or more findings.
  Iterable<Finding> evaluate(SemanticsSnapshot snapshot, RuleContext ctx);
}
```

`RuleContext` carries configuration (thresholds, target-size mode, ignores). A rule reads from it but never mutates it.

## Non-negotiable requirements for every new rule

A rule is not mergeable unless **all** of these hold:

1. **A `Criterion`.** It cites a specific WCAG success criterion and the corresponding EN 301 549 clause. A finding with no citable criterion is forbidden (this is a `CLAUDE.md` guardrail).
2. **Pack membership is correct.** If the criterion is WCAG 2.2-only (e.g. 2.5.8 Target Size Minimum), the rule must not be active under a WCAG 2.1 / EN 301 549 v3.2.1 pack. Getting this wrong reports violations that do not legally apply.
3. **A violating fixture and a clean fixture** (per `05_TESTING.md`). The clean fixture proving the rule stays silent is mandatory, not optional.
4. **Adversarial fixtures** for every known false-positive trap for this check (per `10_QUALITY_AND_CORRECTNESS.md`).
5. **Correct, actionable fix suggestion.** The `suggestion` on the finding must actually fix the issue, with a code-level hint where possible.
6. **Confidence honesty.** If the check relies on visual/structural inference, it is `heuristic`, tagged as such in output, and trivially suppressible. Do not label a heuristic `deterministic` to make it look stronger.
7. **Dartdoc.** The rule class and its `evaluate` are documented, including what it detects and its known limits.
8. **Determinism.** No dependence on iteration order, hash codes, or wall-clock; identical snapshot ⇒ identical findings.

## Choosing the detection method

- **TREE** (pure snapshot walk) — default; cheapest and most robust. Prefer it.
- **RASTER** (needs `contrastSamples`) — only for checks that require rendered pixels (contrast). Expensive; justify it.
- **TEXTSCALE** (needs `textScaleObservations`) — only for reflow/overflow under enlarged text.

If a rule can be expressed as TREE, it must be. Reach for RASTER/TEXTSCALE only when the criterion genuinely cannot be evaluated from the semantics tree alone.

## Rule ID and stability

- IDs are permanent. `attest/interactive-name` shipped once is `attest/interactive-name` forever; renaming breaks every user's baseline and ignore directives.
- Deprecating a rule: keep the ID, mark it deprecated in docs, optionally default-disable it, and remove only on a major version.

## Severity guidance

- `error` — a clear, deterministic barrier for an assistive-tech user (missing name, insufficient contrast, unreachable control).
- `warning` — a real issue with legitimate exceptions the tool cannot fully resolve (small target with possible spacing exemption), or any heuristic.
- `info` — advisory (e.g. an ignore directive missing its required reason).

When unsure, prefer the lower severity. Over-flagging as `error` is a fast route to losing trust.

## The authoring checklist (paste into every rule PR)

```
[ ] id is 'attest/<kebab-case>' and permanent
[ ] Criterion set (WCAG SC + EN 301 549 clause)
[ ] Correct StandardPack membership (esp. WCAG 2.2-only criteria)
[ ] Detection method is the cheapest that works (TREE unless justified)
[ ] Violating fixture (asserts it fires)
[ ] Clean fixture (asserts it stays silent)
[ ] Adversarial fixtures for known FP traps
[ ] Deterministic (no order/hash/time dependence)
[ ] Confidence honest (heuristic tagged + suppressible)
[ ] Fix suggestion correct and actionable
[ ] Dartdoc with detection summary + limits
[ ] Precision/recall computed on the corpus; no regressions
```

## For contributors: the shape of a rule PR

A good rule PR is small and self-contained: one rule class, its fixtures (violating + clean + adversarial), its corpus entries, and a CHANGELOG line. It does not touch the engine, the data model, or other rules. If a new rule needs engine changes, that is a separate PR reviewed on its own — the engine is load-bearing for every rule and changes to it carry more risk than any single rule.
