# 10 — Quality & Correctness

For a compliance tool, **trust is the product**, and trust is a measured quantity, not a claim. This document defines how `attest` proves it is right. It is the single most important thing separating a world-standard instrument from a hobby scanner. No rule reaches 1.0 stability until it clears the bar here.

## The two failure modes, and which one is fatal

- **False negative (missed violation):** the tool says a screen is fine when it is not. Erodes the tool's *value* — but the user is no worse off than with no tool.
- **False positive (wrong violation):** the tool flags something that is actually fine. Erodes the tool's *trust* — the user stops believing any of its output and rips it out of CI.

**False positives are the fatal class.** A compliance gate that cries wolf gets disabled, and a disabled gate protects no one. So the quality bar is asymmetric: we tolerate a known, documented false-negative gap far more than an unexplained false positive.

## The validation corpus

Build and maintain a corpus of Flutter screens with **hand-labelled ground truth**: for each screen, the set of accessibility issues a human expert confirms, mapped to criteria, plus the screens that are genuinely clean.

- **Positive fixtures:** screens containing exactly one known violation of a given rule (isolate the signal).
- **Clean fixtures:** screens that are correct and must produce zero findings — these guard against false positives and are as important as the positive ones.
- **Real-world screens:** anonymized/reconstructed screens from actual apps, which surface the messy cases synthetic fixtures miss.
- **Adversarial fixtures:** the known false-positive traps — text over gradients (contrast), disabled controls (contrast exemption), decorative-but-excluded images, RTL layouts (focus order), spacing-exempt small targets.

The corpus lives in the repo, is versioned, and grows every time a real bug is found (see "Every bug becomes a fixture" below).

## The metrics we track (and publish)

Per rule, computed against the corpus on every CI run and surfaced as first-class numbers:

- **Precision** = of the findings the rule reported, the fraction that are real. This is the trust metric; guard it fiercely.
- **Recall** = of the real violations, the fraction the rule caught. This is the coverage metric.
- **False-positive rate** on the clean + adversarial fixtures. Target: **zero** on clean fixtures; any regression here fails CI.

Publishing these numbers (in the README / docs) is a competitive weapon: no other Flutter a11y tool can show measured correctness. "Trust us" loses to "here is our precision/recall."

## Cross-validation against real assistive technology

Synthetic correctness is not enough for the checks that model what a screen reader *does*. For the semantics-dependent rules and especially the **transcript**:

- Capture what real **VoiceOver (iOS)** and **TalkBack (Android)** actually announce on a set of reference screens.
- Diff `attest`'s transcript / findings against those captures.
- Agreement with real AT output is the strongest correctness claim we can make, and becomes the headline validation story.

Where our model and the real screen reader disagree, the real screen reader is ground truth, and the discrepancy becomes a tracked bug.

## The contract for a "trustworthy rule" (1.0 bar)

A rule may be marked stable (shipped in 1.0, not `@experimental`) only when all hold:

1. Deterministic checks: **zero** false positives on the clean + adversarial corpus.
2. Heuristic checks: measured false-positive rate below a stated threshold, the rule is tagged `heuristic` in output, and suppression is one line.
3. Precision and recall are computed and recorded; regressions fail CI.
4. Every known false-positive trap for the rule has a dedicated adversarial fixture.
5. The fix suggestion in the finding is correct and actionable (a wrong fix suggestion is itself a trust bug).

## Determinism, performance, and the fingerprint

- **Determinism:** identical input must produce identical output, including ordering. Non-determinism silently corrupts the baseline gate. Test it.
- **Fingerprint stability:** regression-test that a pure layout change does **not** change fingerprints, and that a real violation change **does**. This property is the whole basis of the baseline gate; it is guarded, not assumed. (See `01_ARCHITECTURE.md`.)
- **Performance budget:** a per-screen audit-time budget so per-PR CI stays fast on large suites. Track it; a rule that blows the budget is a rule to optimize, not merge.

## Every bug becomes a fixture

The corpus is how correctness compounds. The rule is absolute: **no correctness bug is closed without a fixture that fails before the fix and passes after.** A false positive reported by a user becomes an adversarial fixture forever. Over time this makes regressions structurally hard — the exact discipline `05_TESTING.md` demands, applied to correctness rather than mechanics.

## Coverage honesty (ties back to the mission)

Correctness includes being honest about what we do **not** check. The output must be able to state, per standard pack, which clauses are covered automatically and which require human review (see `12_STANDARDS_TRACEABILITY.md`). A tool that silently implies full coverage is failing the correctness bar even if every rule it runs is perfect.
