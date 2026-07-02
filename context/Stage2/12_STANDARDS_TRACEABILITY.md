# 12 — Standards Traceability

The thing that makes `attest` a *compliance instrument* rather than a linter is that every finding is traceable to a specific clause of a recognized standard, and that mapping is auditable and kept current. This document defines how we manage that traceability rigorously.

## The standards we map to

- **WCAG 2.1** and **WCAG 2.2** (W3C) — the success-criteria vocabulary (e.g. 1.4.3, 4.1.2, 2.5.8).
- **EN 301 549** — the European harmonized standard the EAA points to. **v3.2.1** incorporates WCAG 2.1 AA; **v4.1.1** (expected 2026) moves to WCAG 2.2. Its clause numbering (e.g. §11.5.2.5) is what auditors and legal cite.

Every `Criterion` in the codebase carries **both** a WCAG success-criterion id and the EN 301 549 clause, plus the level (A/AA) and a short title.

## Versioned standard packs

Standards evolve; our mapping must be versioned, not hard-coded. A **StandardPack** is a named, versioned set of active rules + the criterion mapping in force for that standard version:

- `wcag21_aa`, `wcag22`
- `en301549_v3_2_1` (default today), `en301549_v4_1_1` (add when published)

Rules declare pack membership (`11_RULE_AUTHORING.md`). Selecting a pack determines which rules run and which clause numbers appear in output. This is why WCAG 2.2-only criteria (e.g. 2.5.8 Target Size Minimum) must **not** fire under `en301549_v3_2_1` — reporting a violation of a criterion that does not legally apply under the selected standard is a correctness and credibility failure.

## The criterion registry

Maintain a single source of truth: a registry mapping each WCAG success criterion to its EN 301 549 clause, level, title, and the pack versions it appears in. Rules reference the registry; they never inline their own clause strings. Benefits: one place to audit, one place to update on a standard bump, and impossible-to-drift mappings.

Because WCAG criterion text is copyrighted by the W3C, the registry stores our **own concise paraphrase** of intent plus the criterion id and a link to the official text — never a verbatim copy of the normative wording.

## Coverage matrix — the honesty artifact

For each pack, the tool must be able to emit a coverage matrix: every clause in that standard, marked as one of:

- **Automated** — a rule checks it.
- **Partial** — a rule checks part of it (state which part).
- **Manual** — requires human judgement; out of automated scope (e.g. colour-only meaning, alt-text usefulness, error-message quality, media captions).

This matrix is not a nice-to-have. It is what lets a team assemble a complete audit trail and is the concrete form of the mission's honesty commitment. It also feeds the generated manual-review checklist (see `08_TECHNICAL_ROADMAP.md` Phase 4).

## Keeping current — the standing obligation

- **Track WCAG / EN 301 549 revisions.** When EN 301 549 v4.1.1 lands, add the pack, update the registry, map the new/changed criteria, and publish a migration note. Do not silently change what an existing pack means — that would move users' baselines under them.
- **Never mutate a shipped pack's meaning.** Fixes to mappings that change results are a new pack version or a documented, changelogged correction, not a quiet edit.
- **Semantics-API drift is separate from standards drift.** A Flutter release changing how semantics are exposed (like the 3.32 `flagsCollection` change) affects *detection*, not the *mapping*. Keep the two concerns distinct.

## What traceability buys us

- Engineers get a finding they can act on and cite.
- Auditors get output that maps directly onto the standard they audit against.
- Legal gets clause-level evidence for EAA questions.
- And no competitor that reports generic "WCAG issues" without clause-level, version-correct traceability can match it. This is the wedge — protect it.
