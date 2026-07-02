# CLAUDE.md

This is the entry point for any AI coding session in this repository. Read it fully before writing code. **Then read `09_VISION_AND_GOALS.md` — it is the anchor every other doc serves — and continue through the numbered docs.**

**Stage note:** the initial build is done (`attest` 0.9.0 ships all 12 rules, three detection methods, baseline gate, SARIF/HTML/JSON, transcript, standard packs, CLI). We are now on the **"make it world standard"** stage: proven correctness, auditable standards coverage, a rule set that scales past one maintainer, professional release/support/security discipline, and frictionless adoption. The live plan is `08_TECHNICAL_ROADMAP.md`; the "why" is `09_VISION_AND_GOALS.md`.

## What we are building

`attest` — a **continuous accessibility-compliance toolkit for Flutter**. It runs inside widget tests, walks the Flutter semantics tree, detects accessibility violations, maps each one to a specific success criterion (WCAG 2.1/2.2 + EN 301 549), and gates CI against regressions. The legal driver is the European Accessibility Act (enforceable since 28 June 2025); the structural moat is that Flutter renders to its own canvas, so web a11y tools (axe-core, Lighthouse) do not work on it.

This is an **open-core** project. The packages in this repo are the free OSS core. A paid SaaS/dashboard layer is out of scope for this repo.

## The five non-negotiables

1. **No overclaiming.** This tool never claims to certify "EAA compliance." Automated checks catch ~30–40% of accessibility issues. The honest framing, repeated in README and report output, is: *"automated coverage of machine-checkable criteria, plus a structured checklist for the rest."* See `00_PROJECT_BRIEF.md` §Scope.
2. **Trust is the product — prove correctness, don't claim it.** No rule reaches 1.0 stability without a validation corpus, tracked precision/recall, and zero false positives on clean fixtures. False positives are the fatal failure mode: a compliance gate that cries wolf gets disabled. See `10_QUALITY_AND_CORRECTNESS.md`.
3. **Google/Flutter-grade quality.** Every public member is documented with dartdoc. `dart analyze` is clean under `flutter_lints`. `dart format` is applied. The package targets a high pub.dev/pana score. See `04_CONVENTIONS.md`.
4. **The core is pure Dart.** Rules operate on a serializable `SemanticsSnapshot`, never on live Flutter types. This makes every rule unit-testable without a widget tester. Flutter-specific work (pumping, rasterizing) lives only in the Flutter-facing package. See `01_ARCHITECTURE.md`.
5. **Ergonomics first.** The developer-facing API is one obvious call with sensible defaults. If using the library is awkward, the design is wrong. See `02_API_DESIGN.md`.

## Repository layout (melos monorepo)

```
packages/
  attest/         # pure Dart core: data model, rule engine, TREE rules, reporting, baseline
  attest_flutter/ # Flutter: WidgetTester extension, RASTER + TEXTSCALE collectors, matcher
  attest_cli/     # Dart CLI: aggregates test output, baseline gate, SARIF/HTML report
example/              # an intentionally-broken demo app used for dogfooding + CI
docs/                 # the numbered docs below
```

Dependency direction is one-way: `attest_flutter` and `attest_cli` depend on `attest`. The core depends on nothing Flutter.

## Read order

1. `00_PROJECT_BRIEF.md` — why this exists, scope, what is explicitly out.
2. `01_ARCHITECTURE.md` — packages, data model, detection methods, engine flow.
3. `02_API_DESIGN.md` — the public API and its ergonomics.
4. `03_RULESET.md` — the 12 starter rules with detection logic and standard mapping.
5. `04_CONVENTIONS.md` — Dart/Flutter conventions, lints, docs, versioning.
6. `05_TESTING.md` — how this package tests itself (an auditor must be impeccable).
7. `06_ROADMAP.md` — the initial *build* roadmap (M0–M8). Now complete; kept for reference.
8. `07_COMPETITIVE_LANDSCAPE.md` — who else exists and exactly how we differ. Read before writing the README or any positioning copy.
9. `08_TECHNICAL_ROADMAP.md` — the *forward* roadmap (0.9 → 1.0 → beyond). This is the live plan; work from it now.
10. `09_VISION_AND_GOALS.md` — **the anchor.** Mission, vision, definition of success, non-goals, guiding principles. Read early; everything serves this.
11. `10_QUALITY_AND_CORRECTNESS.md` — how we prove the tool is right (corpus, precision/recall, real-AT cross-validation). The world-standard differentiator.
12. `11_RULE_AUTHORING.md` — the public Rule API and the contract every rule must satisfy, so the set scales past one maintainer.
13. `12_STANDARDS_TRACEABILITY.md` — rigorous, versioned, auditable WCAG / EN 301 549 mapping and the coverage matrix.
14. `13_RELEASE_AND_SUPPORT.md` — semver across the three packages, release process, support and deprecation policy.
15. `14_GOVERNANCE_AND_CONTRIBUTING.md` — how the project is run, how people contribute, security disclosure, community files to generate.
16. `15_PHASE1_PLAN.md` — the executable Phase 1 breakdown (tasks + DoD): the corpus, the precision/recall harness, and the 1.0 gate. **This is what to work on right now.**

## How to work

- **Verify current versions yourself.** Do not trust version numbers from these docs. Before pinning any dependency, run `dart pub` / check pub.dev for the current stable version (`flutter_lints`, `meta`, `collection`, the Dart/Flutter SDK constraint, etc.).
- **Work from `08_TECHNICAL_ROADMAP.md`**, guided by `09_VISION_AND_GOALS.md`. The initial build (`06_ROADMAP.md`) is complete; the current focus is Phase 1 — hardening to a validated, stable 1.0.
- **Commands** (after `dart pub global activate melos`):
  - `melos bootstrap` — link the workspace.
  - `melos run analyze` — `dart analyze` across all packages; must be clean.
  - `melos run format` — `dart format .`.
  - `melos run test` — all unit + widget + golden tests.
  - `dart doc` — must generate without warnings on public members.
  - `dart pub global run pana` (on each package) — sanity-check the score before publishing.

## Definition of done for any change

A unit of work is done only when all of these hold: tests cover it (a violating fixture and a clean fixture for any rule), `dart analyze` is clean, `dart format` applied, every new public member has dartdoc with at least one example, and the public API surface did not break without a corresponding semver major bump and CHANGELOG entry.

## Guardrails

- Do not export anything from `lib/src/` directly; expose a curated barrel file in `lib/`.
- Do not introduce a Flutter dependency into the `attest` core package.
- Do not add a rule without a standard mapping (`Criterion`) — a finding with no citable criterion is not allowed.
- Do not weaken the honesty framing to make the tool sound more capable.
- Do not mark a rule stable / ship it in 1.0 without meeting the correctness bar in `10_QUALITY_AND_CORRECTNESS.md` (corpus + tracked precision/recall + zero FP on clean fixtures).
- Do not rename a rule ID or change a shipped standard pack's meaning — both silently move users' baselines. Treat as breaking changes.
- Do not add network calls or telemetry to the OSS packages. It runs in CI; it never phones home.
