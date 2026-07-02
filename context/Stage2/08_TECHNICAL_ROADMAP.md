# 08 — Technical Roadmap (0.9 → 1.0 → beyond)

**You are here:** `attest` 0.9.0 is published. The entire *build* roadmap (`06_ROADMAP.md`) is complete — 12 rules across TREE/RASTER/TEXTSCALE, baseline gate, SARIF/HTML/JSON, screen-reader transcript, versioned standard packs, and the CLI. That document got the thing *built*. **This document is the forward roadmap:** turning a feature-complete core into a *trusted, adopted, deep* compliance instrument.

## The one sequencing principle

For a compliance tool, **trust is the product.** A tool people wire into CI as a "judge of conformance" is worthless the moment it is wrong. So: **do not add breadth before the existing surface is validated and stable.** Correctness and adoption beat rule count. Let real usage — not ambition — order the later phases.

## Phase overview

| Phase | Theme | Outcome | Start when |
|---|---|---|---|
| 1 | Harden to 1.0 | Validated, stable, identity-verified | **now** |
| 2 | Static-surface depth | More machine-checkable criteria | after 1.0 |
| 3 | Interaction-aware auditing | Audits across interactions, not one static screen | after 1.0, when real users exist |
| 4 | Compliance surface | Coverage matrix, manual checklist, conformance export | in parallel with 2–3 |
| 5 | DX & ecosystem | IDE lints, integration_test, CI action, DevTools | driven by adoption friction |
| 6 | Platform breadth & scale | Web/desktop, org rollup, incremental audits | when demand appears |

---

## Phase 1 — Harden to 1.0 (trust & stability) — *do this now*

The features exist; make them trustworthy and freeze them.

- **API stability audit & freeze.** Walk the entire public surface; annotate anything not ready with `@experimental`; write a short stability policy; cut **1.0.0**. For the enterprise buyer, "1.0, stable API" is the signal that it is safe to build into a pipeline.
- **Correctness corpus.** Build a fixture suite of screens with hand-labelled, known WCAG issues (and known-clean screens). Measure **precision and recall per rule** and treat those numbers as first-class, tracked metrics. This is the single highest-leverage work in the whole roadmap — it is what makes the tool credible.
- **Reference-validate the hard paths.** Contrast math against a reference implementation and known colour pairs; overflow against goldens; **the transcript against real VoiceOver/TalkBack captures**. If the transcript matches what the screen readers actually announce, that becomes your strongest marketing claim.
- **Heuristic tuning.** Drive down false positives on the three heuristic rules (`heading-structure`, `focus-order`, `state-exposed`): measure FP rate on the corpus, make suppression frictionless, and demote any persistently-noisy rule to opt-in rather than let it erode trust.
- **Determinism & a performance budget.** Guarantee stable output ordering and fingerprint stability (regression test it). Set a per-screen audit-time budget so per-PR CI stays fast on large test suites.
- **Support policy & SDK floors.** Adopt "supports the latest N stable Flutter releases"; lower the pure-Dart core's `environment.sdk` to its true minimum (keep `attest_flutter` on 3.32+ for the tri-state semantics API). Document both.
- **Verified publisher + provenance** on pub.dev, so the tool running in people's CI has a verified identity, not "unverified uploader."

**Definition of 1.0:** frozen, documented public API; published stability + support policy; a correctness corpus with tracked precision/recall; verified publisher; complete docs and a real-world validation write-up.

---

## Phase 2 — Depth on the static surface (more criteria, done right)

Only after 1.0. Each new rule ships with violating + clean fixtures and an explicit clause mapping — no rule without a `Criterion`.

- **4.1.3 Status Messages / live regions** (`SemanticsService.announce`, `liveRegion`) — a strong, Flutter-specific differentiator few tools touch.
- **1.4.11 Non-text Contrast** (UI-component and graphical-object contrast) — extends the raster collector beyond text.
- **2.4.7 Focus Visible**, **1.3.5 Identify Input Purpose** (autofill hints), **1.3.4 Orientation**, **1.4.12 Text Spacing**.
- **3.1.1 / 3.1.2 Language of page / parts** (locale tagging on text).

Keep deferring the criteria that need human judgement (colour-only meaning, alt-text usefulness, error-message quality). The honesty line is a feature, not a gap.

---

## Phase 3 — Interaction-aware auditing (the big technical leap)

Today the tool audits a single, static, pumped screen. The next frontier is auditing **across interactions** — and nobody does this for Flutter.

- Drive the widget through a scripted sequence (tap / scroll / navigate), re-snapshot after each step, and detect issues that only exist in motion: focus traps that appear after navigation, semantics that break on state change, **missing announcements after an action**, focus that fails to move to newly-presented content (dialogs, routes, sheets).
- Provide a small "interaction script" layer on top of the `WidgetTester` so an audited flow reads declaratively.
- This deepens the moat decisively versus static analyzers (which never render) and single-screen scanners.

---

## Phase 4 — Compliance surface (the wedge — keep as much in OSS as possible)

Runs in parallel with Phases 2–3; it is what the paying buyer actually cares about.

- **Coverage matrix in output:** per standard pack, "clauses we cover automatically" vs "clauses that require human review." Honest and immediately useful.
- **Generated manual-review checklist tied to the app's actual screens,** so a team gets a *complete* audit trail (automated findings + the human-only items). This is the artifact auditors want and it directly backs the honesty framing.
- **Machine-readable conformance export** (findings → EN 301 549 / WCAG clause) as the *stable substrate* the paid report/dashboard consumes. Keep this format stable so the paid layer stays a thin consumer.
- **Standards tracking:** complete WCAG 2.2 coverage and add the **EN 301 549 v4.1.1** pack when it lands, with a migration note on version bumps.

The hosted dashboard, the PR-annotation service, and the polished VPAT / EU accessibility-statement PDF remain the **paid** layer (out of this repo). The OSS core just needs to emit stable, complete, clause-mapped data.

---

## Phase 5 — Developer experience & ecosystem (adoption)

Lower friction; meet developers where they already are.

- **`custom_lint` / analyzer plugin** exposing a fast subset of checks as IDE-time lints — complements the deep test-time checks and competes with the static-analyzer packages on their own turf, without giving up runtime depth.
- **`integration_test` support:** audit the *real rendered app* on device/emulator, not only widget tests — catches platform-channel and native-semantics differences.
- **Turnkey CI:** a published GitHub Action and GitLab template; SARIF PR annotations working out of the box.
- **Ergonomics:** presets (`strict` / `standard` / `lenient`), a config file, per-rule severity overrides, a one-liner `testAccessibility(MyApp())` helper.
- **DevTools extension:** live semantics-tree + findings overlay while debugging.

---

## Phase 6 — Platform breadth & scale

When demand shows up (don't pre-build).

- **Flutter web / desktop specifics:** web emits an ARIA/DOM semantics layer worth auditing against web expectations; desktop needs keyboard-navigation coverage.
- **Incremental / cached audits** and **org-level rollup** for large monorepos (bridges naturally to the paid dashboard).
- **RTL / localization-aware** coverage beyond the current focus-order handling.

---

## Cross-cutting (continuous, every phase)

- **Public Rule API + rule-authoring guide** so the community can contribute rules — each with a clause mapping and violating/clean fixtures. This is how a rule set outgrows one maintainer.
- **Deprecation discipline & versioned packs;** changelog rigor; never break the public API without a major bump.
- **Zero telemetry by default.** It runs in CI; it must never phone home. Privacy is part of the trust story.
- **Track every new stable Flutter within one release cycle.** Semantics-API drift (like the 3.32 `flagsCollection` change) is the standing maintenance tax; budget for it.

## Prioritization heuristic (use inside every phase)

Prefer work that maximizes **(user-visible trust) × (low false-positive risk) × (reuses existing infrastructure)** first. Do not begin speculative Phase 3+ work until Phase 1 (trust) is done and real users exist — then let adoption signals, not ambition, order Phases 4–6.
