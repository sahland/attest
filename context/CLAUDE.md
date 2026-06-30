# CLAUDE.md

This is the entry point for any AI coding session in this repository. Read it fully before writing code, then read the numbered docs in order.

## What we are building

`a11y_audit` — a **continuous accessibility-compliance toolkit for Flutter**. It runs inside widget tests, walks the Flutter semantics tree, detects accessibility violations, maps each one to a specific success criterion (WCAG 2.1/2.2 + EN 301 549), and gates CI against regressions. The legal driver is the European Accessibility Act (enforceable since 28 June 2025); the structural moat is that Flutter renders to its own canvas, so web a11y tools (axe-core, Lighthouse) do not work on it.

This is an **open-core** project. The packages in this repo are the free OSS core. A paid SaaS/dashboard layer is out of scope for this repo.

## The four non-negotiables

1. **No overclaiming.** This tool never claims to certify "EAA compliance." Automated checks catch ~30–40% of accessibility issues. The honest framing, repeated in README and report output, is: *"automated coverage of machine-checkable criteria, plus a structured checklist for the rest."* See `00_PROJECT_BRIEF.md` §Scope.
2. **Google/Flutter-grade quality.** Every public member is documented with dartdoc. `dart analyze` is clean under `flutter_lints`. `dart format` is applied. The package targets a high pub.dev/pana score. See `04_CONVENTIONS.md`.
3. **The core is pure Dart.** Rules operate on a serializable `SemanticsSnapshot`, never on live Flutter types. This makes every rule unit-testable without a widget tester. Flutter-specific work (pumping, rasterizing) lives only in the Flutter-facing package. See `01_ARCHITECTURE.md`.
4. **Ergonomics first.** The developer-facing API is one obvious call with sensible defaults. If using the library is awkward, the design is wrong. See `02_API_DESIGN.md`.

## Repository layout (melos monorepo)

```
packages/
  a11y_audit/         # pure Dart core: data model, rule engine, TREE rules, reporting, baseline
  a11y_audit_flutter/ # Flutter: WidgetTester extension, RASTER + TEXTSCALE collectors, matcher
  a11y_audit_cli/     # Dart CLI: aggregates test output, baseline gate, SARIF/HTML report
example/              # an intentionally-broken demo app used for dogfooding + CI
docs/                 # the numbered docs below
```

Dependency direction is one-way: `a11y_audit_flutter` and `a11y_audit_cli` depend on `a11y_audit`. The core depends on nothing Flutter.

## Read order

1. `00_PROJECT_BRIEF.md` — why this exists, scope, what is explicitly out.
2. `01_ARCHITECTURE.md` — packages, data model, detection methods, engine flow.
3. `02_API_DESIGN.md` — the public API and its ergonomics.
4. `03_RULESET.md` — the 12 starter rules with detection logic and standard mapping.
5. `04_CONVENTIONS.md` — Dart/Flutter conventions, lints, docs, versioning.
6. `05_TESTING.md` — how this package tests itself (an auditor must be impeccable).
7. `06_ROADMAP.md` — milestones with definition-of-done; build in this order.
8. `07_COMPETITIVE_LANDSCAPE.md` — who else exists and exactly how we differ. Read before writing the README or any positioning copy.

## How to work

- **Verify current versions yourself.** Do not trust version numbers from these docs. Before pinning any dependency, run `dart pub` / check pub.dev for the current stable version (`flutter_lints`, `meta`, `collection`, the Dart/Flutter SDK constraint, etc.).
- **Build in the order in `06_ROADMAP.md`.** After Milestone 1, the OSS package is already publishable; everything after is additive and must not require rewriting the core.
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
- Do not introduce a Flutter dependency into the `a11y_audit` core package.
- Do not add a rule without a standard mapping (`Criterion`) — a finding with no citable criterion is not allowed.
- Do not weaken the honesty framing to make the tool sound more capable.
