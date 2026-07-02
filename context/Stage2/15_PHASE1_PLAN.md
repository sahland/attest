# 15 — Phase 1 execution plan (harden to a validated 1.0)

This turns Phase 1 of `08_TECHNICAL_ROADMAP.md` into build-ready tasks with definitions of done, applying the correctness discipline from `10_QUALITY_AND_CORRECTNESS.md`. Deepest detail is on the two things that unlock everything else: the **correctness corpus** and the **precision/recall harness**. Build those first — until you can measure correctness, every other task is unmeasurable.

**Phase 1 goal:** a validated, stable, identity-verified **1.0** — the same features you already have, but proven right and frozen.

## Workstream map & order

```
P1.1 Corpus format + snapshot `identifier`      ─┐  (foundation — do first)
P1.2 Metrics harness (precision/recall/FP)       ┘
        │
        ├── P1.3 Populate corpus per rule
        ├── P1.4 Heuristic tuning (uses metrics)
        ├── P1.5 Reference-validate hard paths (contrast / overflow / transcript)
        ├── P1.6 Determinism, fingerprint, performance budget
        ├── P1.8 Support policy + SDK floors
        └── P1.9 Verified publisher (operational, parallel)
        │
P1.7 API freeze + @experimental gating  ── near the end, gates 1.0
```

---

## P1.1 — Corpus format + a ground-truth anchor

Before any metric, define how a labelled case is expressed. A **corpus case** = an input (a pure-Dart `SemanticsSnapshot` fixture *or* a real widget) + a human-authored ground-truth label.

**Ground-truth anchoring — the key decision.** Do not match findings to expectations by source location (brittle) or fingerprint (that's for the baseline gate). Anchor on a **semantics `identifier`**: tag the intended-offending node in the fixture, and reference that id in the expectation.

- Add an `identifier` field to `SemanticsNodeData` (captured from `SemanticsProperties.identifier` in the snapshot builder; set directly in pure-Dart fixtures). Small model addition, broadly useful.
- In widget fixtures, tag offenders with `Semantics(identifier: 'offender.pay-button', ...)`.

```dart
enum CorpusCategory { positive, clean, adversarial, realWorld }

class ExpectedFinding {
  final String ruleId;      // 'attest/interactive-name'
  final String wcag;        // '4.1.2'
  final String identifier;  // semantics identifier of the offending node
}

class CorpusCase {
  final String id;                 // 'checkout_unnamed_pay_button'
  final CorpusCategory category;
  final StandardPack pack;         // which pack to audit under
  final FutureOr<AuditInput> Function() build; // snapshot or pumpable widget
  final List<ExpectedFinding> expected; // [] for clean/adversarial-that-must-be-silent
}
```

Isolation policy: **positive** and **adversarial** cases isolate one rule (only findings from the rule under test are relevant, and the case is fully labelled for it). **realWorld** cases enable all rules and must be fully labelled across every rule. This keeps most labels cheap while a few composite cases test realism.

**DoD P1.1:** `SemanticsNodeData` has `identifier`; the snapshot builder captures it; `CorpusCase`/`ExpectedFinding` types exist with round-trippable JSON; a directory convention (`corpus/<rule>/<case>.dart`) is documented; three sample cases (one positive, one clean, one adversarial) compile and load.

---

## P1.2 — The precision/recall harness

The harness runs every corpus case, matches actual findings to expected, and computes per-rule metrics.

**Matching algorithm (deterministic):**

```
for each CorpusCase c:
  actual = engine.audit(c.build(), pack: c.pack).findings
  # map each actual finding to the identifier of its node or nearest ancestor identifier
  for each expected E in c.expected:
     A = actual.firstWhereOrNull((a) =>
           a.ruleId == E.ruleId &&
           a.criterion.wcag == E.wcag &&
           identifierOf(a) == E.identifier)
     if A != null: TP++, consume A
     else:         FN++          # a real violation we missed
  # any unconsumed actual (for a rule in scope for this case) is a false positive
  for each leftover A in actual (rule in scope): FP++
  # clean category: every actual finding is an FP by definition
```

`identifierOf(finding)` resolves the finding's node to its own `identifier`, or walks ancestors in the snapshot to the nearest one. If a fixture's offender has no identifier, that's an authoring error the harness reports loudly.

**Metrics, per rule, aggregated across all cases:**
- precision = TP / (TP + FP)
- recall = TP / (TP + FN)
- fpRateOnClean = (FP on clean cases) / (clean cases) — target **0**

**Output:** a JSON report (`build/metrics/metrics.json`) plus a human table. Commit a `metrics_baseline.json`.

**CI gate (`attest_metrics` command or a test):** fail the build if any of:
- a **deterministic** rule has precision < 1.0 on the corpus (deterministic rules must not false-positive on labelled data),
- a **heuristic** rule has precision below its declared threshold,
- any FP on a **clean** case,
- recall regresses more than a small tolerance below `metrics_baseline.json`.

**DoD P1.2:** harness computes TP/FP/FN + precision/recall/fpRateOnClean per rule over the corpus; emits JSON + table; a metrics baseline is committed; the CI gate fails on the four conditions above; the harness itself is unit-tested with a tiny synthetic corpus where the expected metrics are known by hand.

---

## P1.3 — Populate the corpus per rule

Now scale the labelled data. Minimum viable per rule: **~4 positive, ~2 clean, ~2 adversarial**, targeting the known false-positive traps for that rule (from `03_RULESET.md`): contrast over gradients + disabled-control exemption; decorative-but-excluded images; RTL focus order; spacing-exempt small targets; placeholder-vs-real labels; hintText-is-not-a-label; etc. Add a handful of `realWorld` composite screens.

**DoD P1.3:** every one of the 12 rules has ≥4 positive, ≥2 clean, ≥2 adversarial cases; each known FP trap in `03_RULESET.md` has a dedicated adversarial case; ≥5 realWorld composite cases exist and are fully labelled; the harness runs green under the gate; a short `corpus/README.md` explains how to add a case.

---

## P1.4 — Heuristic tuning (measured, not guessed)

For the three heuristics (`heading-structure`, `focus-order`, `state-exposed`): use the harness to measure FP-rate, tune thresholds against the corpus, and declare each rule's precision threshold. If a rule stays noisy after tuning, **default-disable it (opt-in)** rather than let it erode trust — a documented, honest choice.

**DoD P1.4:** each heuristic has a declared precision threshold met on the corpus; any rule that can't meet a reasonable threshold is default-disabled with a documented rationale; all three are tagged `heuristic` in output and suppressible in one line.

---

## P1.5 — Reference-validate the hard paths

Where synthetic fixtures aren't enough:

- **Contrast (RASTER):** a table of known colour pairs with independently-computed expected ratios; assert the collector's ratio within ±0.1. Adversarial: text over gradient/image must abstain or `warning`, never a false hard `error`.
- **Overflow (TEXTSCALE):** fragile layouts must produce an overflow observation at scale 2.0 and none at 1.0.
- **Transcript vs real AT (semi-manual):** pick 5–10 reference screens; manually capture what **VoiceOver** and **TalkBack** actually announce (document the capture procedure); store as expected transcripts; the harness diffs `attest`'s transcript against them. Where they disagree, the screen reader is ground truth and the gap becomes a tracked bug + fixture.

**DoD P1.5:** contrast validated on ≥10 known pairs within tolerance + adversarial abstention proven; overflow validated at 1.0/2.0; ≥5 screens have captured VoiceOver+TalkBack transcripts with a documented capture procedure, and the transcript diff runs in CI; every disagreement is either fixed or filed with a fixture.

---

## P1.6 — Determinism, fingerprint stability, performance budget

- **Determinism test:** audit the same input twice; assert byte-identical output including ordering.
- **Fingerprint stability test:** mutate only layout coordinates → fingerprints unchanged; mutate the actual violation → fingerprint changes. (This is the load-bearing property of the baseline gate — see `01_ARCHITECTURE.md`.)
- **Performance budget:** measure per-screen audit time; set an explicit budget (e.g. a target ceiling per screen) and track it; a rule that blows it gets optimized, not merged.

**DoD P1.6:** determinism test green; both fingerprint-stability directions tested; a per-screen time budget is defined, measured in CI, and currently met.

---

## P1.7 — API freeze + `@experimental` gating (gates 1.0)

Near the end of Phase 1: enumerate the entire public surface of all three packages (via `dart doc` / an API report). For each member decide **stable or experimental**; annotate experimental ones with `@experimental` (from `package:meta`). Write the short stability policy (`13_RELEASE_AND_SUPPORT.md`). Nothing not-ready stays un-annotated in the stable surface.

**DoD P1.7:** every public member is either stable-and-documented or `@experimental`; the stability policy is written; `dart doc` is clean; a reviewer has signed off that the frozen surface is one we can commit to for the 1.0 major.

---

## P1.8 — Support policy + SDK floors

Audit the language features the pure-Dart `attest` core actually uses and set its `environment.sdk` to the true minimum (do **not** inherit 3.6 from the workspace). Keep `attest_flutter` at Flutter ≥ 3.32 for the tri-state semantics API. Write the "latest N stable Flutter" support policy.

**DoD P1.8:** core floor set to its verified true minimum with a note on what feature sets it; `attest_flutter` floor documented with its reason; support policy stated in README and `13_RELEASE_AND_SUPPORT.md`.

---

## P1.9 — Verified publisher (operational, parallel)

Set up the pub.dev verified publisher for `sahland.tech`: Google Search Console **Domain property** for the apex, the `google-site-verification` TXT on `@` (not a subdomain), then create the publisher on pub.dev with the same Google account. Republish the three packages under the verified publisher.

**DoD P1.9:** pub.dev shows the verified `sahland.tech` badge (not "unverified uploader") on all three packages.

---

## Phase 1 complete — the 1.0 gate

Cut **1.0.0** only when **all** hold:

- Corpus exists and is green under the metrics gate (P1.2–P1.3).
- Every rule meets its correctness bar from `10` (deterministic: precision 1.0 on corpus, zero FP on clean; heuristic: declared threshold met, tagged, suppressible).
- Hard paths reference-validated; transcript agrees with captured real-AT output or gaps are filed (P1.5).
- Determinism + fingerprint stability + performance budget all tested and met (P1.6).
- Public API frozen; experimental surface annotated; stability + support policies published (P1.7–P1.8).
- Verified publisher live (P1.9).
- README states measured precision/recall and the honest coverage framing.

That last line is the payoff: shipping 1.0 with **published, measured correctness** is something no other Flutter accessibility tool can currently claim — it is the concrete first step from "built" to "world standard."
