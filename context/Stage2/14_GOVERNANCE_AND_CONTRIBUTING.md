# 14 — Governance & Contributing

A project that depends on one person is not a world standard; it is a bus-factor risk. This document defines how `attest` is run, how outsiders contribute, and how the project stays healthy as it grows past its founder.

## Governance model (start simple, formalize as it grows)

- **Now (founder-led):** the maintainer sets direction, guided by `09_VISION_AND_GOALS.md`. Decisions are made in the open (issues/PRs), and the guiding principles in doc 09 are the tie-breakers, not personal preference.
- **Next (small maintainer team):** as trusted contributors emerge, grant them commit/publish rights via the verified publisher's team feature. Document who can release and who reviews what.
- **Later (lightweight RFC process):** for changes to the engine, the public API, the Rule contract, or standards handling, use a short written proposal so the decision and its rationale are recorded. Rule additions do not need an RFC; architectural changes do.

Keep governance proportional to size. Do not import heavyweight process before the project needs it.

## Decision principles

When contributors disagree, resolve in this order (from doc 09): trust over reach, honesty over marketing, correctness over breadth, ergonomics over configurability, openness over lock-in. Cite the principle when making the call, so decisions are legible and consistent rather than arbitrary.

## Contribution path

Make it easy to contribute well and hard to contribute harm:

- **Good first contributions:** new rules (the Rule contract in `11_RULE_AUTHORING.md` makes these self-contained and reviewable), fixtures for the correctness corpus, documentation, and real-world bug reports that become adversarial fixtures.
- **Higher-risk contributions:** engine, data model, standards registry, release tooling — reviewed more strictly and, past the "later" stage, gated behind an RFC.
- **Every PR must satisfy the relevant checklist** (rule-authoring checklist for rules, definition-of-done in `CLAUDE.md` for everything) and keep CI green.

## Community files to generate (real root files, not just guidance)

A world-standard repo has these at the root; generate them as actual files:

- `CONTRIBUTING.md` — how to set up the monorepo (`melos bootstrap`), run checks, the PR checklists, and the rule-authoring path. Point to the relevant docs rather than duplicating them.
- `CODE_OF_CONDUCT.md` — adopt the Contributor Covenant (standard, recognized); do not hand-roll one.
- `SECURITY.md` — the disclosure process below.
- Issue/PR templates — a bug template that captures Flutter/Dart version, a minimal repro widget, and the actual vs expected finding; a rule-proposal template mirroring the authoring checklist.
- `LICENSE` — a permissive license consistent with the Flutter ecosystem (BSD-3-Clause or MIT); pick one and be consistent across packages.

## Security disclosure

`attest` runs inside CI with access to source and the build environment, so security matters more than for a typical library.

- Provide a private disclosure channel (a security email or GitHub private advisory), documented in `SECURITY.md`. Do **not** ask reporters to open public issues for vulnerabilities.
- Acknowledge reports promptly, fix under embargo, and ship an expedited release with an advisory (see `13_RELEASE_AND_SUPPORT.md`).
- Never add network calls or telemetry to the OSS packages. A tool that runs everywhere in CI and phones home is a security and trust liability; "zero telemetry by default" (doc 09) is also a security stance.

## Maintainer health

- **Document as you go.** These context docs are why a second maintainer can be productive quickly; keep them current as the source of truth.
- **Automate the boring guarantees.** Analyze, format, test, coverage, pana, and correctness metrics all run in CI so quality does not depend on anyone remembering.
- **The corpus is institutional memory.** Every bug that becomes a fixture (doc 10) is knowledge that outlives whoever fixed it. This is how the project's correctness survives maintainer turnover.

## What "healthy" looks like

More than one person can cut a release. A new contributor can add a validated rule without touching the engine. A standards revision can be absorbed by updating the registry and packs. A reported false positive becomes a permanent fixture. None of these depend on the founder being available. That independence — not any single feature — is what graduates the project to world standard.
