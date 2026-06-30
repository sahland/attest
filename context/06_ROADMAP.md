# 06 — Roadmap (build in this order)

Each milestone has a definition of done (DoD). Do not start a milestone until the previous one's DoD holds. After **M1**, the OSS package is publishable; everything after is additive and must not require rewriting the core.

## M0 — Scaffold

Set up the melos monorepo and the three packages with correct dependency directions. Wire `analysis_options.yaml` (flutter_lints + extra strictness), formatting, and a CI workflow that runs analyze/format/test. Create empty barrels and the package READMEs/CHANGELOGs.

**DoD:** `melos bootstrap`, `melos run analyze`, `melos run format`, `melos run test` all pass on an empty skeleton; CI is green.

## M1 — Core engine + first four rules (publishable)

Implement the data model (`SemanticsSnapshot`, `SemanticsNodeData`, `Finding`, `Criterion`, `AuditReport`) with JSON round-trip and value equality. Implement the `Rule` interface, the `RuleEngine`, the fixture DSL, and the first four TREE rules: `a11y/interactive-name`, `a11y/image-alt`, `a11y/placeholder-name`, `a11y/field-label`. Implement `SemanticsSnapshotBuilder` and `tester.auditAccessibility()` (TREE only) and the `passesAccessibilityGate()` matcher. Build the broken `example/` app covering these four rules.

**DoD:** each rule has violating + clean unit tests; the example app's audit finds exactly the catalogued defects; `dart analyze` clean; every public member documented; `pana` score sanity-checked. The package can be published to pub.dev as `0.1.0`.

## M2 — Geometry & reachability rules

Add `a11y/target-size`, `a11y/focus-trap`, `a11y/ambiguous-name`. These extend the TREE engine; no new infrastructure.

**DoD:** rules tested (incl. RTL and spacing edge cases); example app extended; CHANGELOG + minor version bump.

## M3 — Text-scale rule (TEXTSCALE collector)

Add the TEXTSCALE collector to `a11y_audit_flutter` and the `a11y/text-overflow` rule. Wire `textScales` config and overflow capture.

**DoD:** collector tested against a fragile layout (fails at 2.0, clean at 1.0); rule reads observations; documented; example app gains an overflow screen.

## M4 — Contrast rule (RASTER collector)

The heaviest engineering. Add the RASTER collector (rasterize via `RepaintBoundary.toImage`, sample glyph vs background, compute WCAG luminance/contrast) and the `a11y/contrast` rule, including the disabled-control exemption and borderline-→warning handling.

**DoD:** golden/pixel tests for known colour pairs within tolerance; disabled controls excluded; documented; example app gains a low-contrast screen.

## M5 — Heuristic rules

Add `a11y/heading-structure`, `a11y/state-exposed`, `a11y/focus-order`, all tagged `heuristic` with easy bulk-suppression and a visible disclaimer in output.

**DoD:** each has tuned thresholds and explicit false-positive tests; documented as heuristic; opt-out via config verified.

## M6 — CI tooling

Build `a11y_audit_cli`: report aggregation, baseline diff by fingerprint, JSON/SARIF/HTML output, and the `baseline --update` command. Add the fingerprint-stability test from `05_TESTING.md`.

**DoD:** baseline gate proven by tests (new-finding detection, fingerprint stability under layout change); SARIF validated against schema; a sample GitHub Actions workflow documented in the README.

## M7 — Screen-reader transcript

Add the `transcript` mode: walk the snapshot in traversal order and emit the sequence of announcements TalkBack/VoiceOver would produce. Print to CI logs and expose via the CLI.

**DoD:** transcript tested against fixtures with known traversal order; documented as a first-class feature (it is the differentiator).

## M8 — Standard packs & WCAG 2.2 readiness

Formalize versioned rule packs (`Standard.en301549_v3_2_1`, `Standard.wcag22`). Ensure rules declare which packs they belong to and that selecting a pack filters them correctly. Prepare for EN 301 549 v4.1.1.

**DoD:** pack selection tested; switching standards changes the active rule set and the criteria cited in output; documented migration note.

---

## Out of scope for this repo

The paid layer — hosted dashboard, PR-annotation GitHub App, conformance-report PDF, and the draft EU accessibility statement generator — is a separate product built on top of the CLI's JSON/SARIF output. Do not build it here. Keep the OSS packages self-sufficient and the output formats stable so that layer can consume them cleanly.
