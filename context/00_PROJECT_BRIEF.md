# 00 — Project Brief

## The problem

Accessibility is now a legal requirement, not a nice-to-have, for a large class of apps sold in the EU. The European Accessibility Act (Directive (EU) 2019/882) has been enforceable since **28 June 2025**; first lawsuits were filed in France in November 2025, and national authorities (Netherlands, Germany, Sweden) are ramping enforcement through 2026. Penalties range into the hundreds of thousands of euros (up to ~€900k / 10% of turnover in some states). Only very small businesses (<10 staff or <€2M turnover) are exempt — meaning the affected audience is precisely the cohort that buys tooling.

The technical standard is **EN 301 549 v3.2.1**, which incorporates **WCAG 2.1 Level AA** in full. The next version (**v4.1.1**, expected 2026) moves to **WCAG 2.2**.

For Flutter specifically there is a structural gap: **Flutter renders to its own canvas, not the DOM.** The entire ecosystem of web accessibility tooling (axe-core, Lighthouse, WAVE) cannot inspect a Flutter mobile/desktop app. What exists on pub.dev today are dev-time overlays and one-off scanners — useful linters, but not compliance instruments. None of them produce a citable, code-anchored conformance artifact, gate CI against regressions, or map findings to specific standard clauses.

## What we are building

A **continuous accessibility-compliance instrument**, structured in three layers:

1. **Rule engine (this repo's OSS core).** Pure Dart. Each rule is a check bound to a specific success criterion, emitting structured findings with code location, severity, and a fix suggestion. Rules are grouped into versioned packs (WCAG 2.1 AA, WCAG 2.2, EN 301 549).
2. **Test + CI integration (this repo).** Runs in ordinary widget tests with no real device. A baseline gate — like code coverage — fails a PR on any *new* violation.
3. **Report + accessibility statement (paid, out of this repo).** Machine-readable conformance report and a draft EU accessibility statement, with every finding traced to its standard clause.

This repo delivers layers 1 and 2.

## Target user

A Flutter team (in-house or agency) shipping a consumer app to EU markets — e-commerce, banking, transport, telecom, ticketing, e-books — that now has a legal obligation and an engineering manager who wants accessibility wired into CI rather than audited once a year by a consultancy.

## Scope

**In scope (v0.1 → v1.0):**
- The pure-Dart rule engine and the 12 starter rules in `03_RULESET.md`.
- A `WidgetTester` extension to audit any pumped screen.
- A matcher for gating tests, plus a CLI that aggregates results, diffs a baseline, and emits JSON/SARIF/HTML.
- A "screen-reader transcript" mode (what TalkBack/VoiceOver would announce, in traversal order) — a differentiator nobody else has.

**Explicitly out of scope (must be stated in README and report output):**
- Anything requiring human judgement: information conveyed by colour alone (1.4.1), meaningfulness of alt text (we see *that* a label exists, not whether it is *useful*), quality of error messages (3.3.x), captions/audio description for media (1.2.x).
- Real assistive-technology testing (TalkBack/VoiceOver). The tool *complements* this; it does not replace it.
- Any claim of certified "EAA compliance."

## Positioning sentence (use verbatim where a one-liner is needed)

> Automated coverage of every machine-checkable accessibility criterion in your Flutter app, anchored to your code and gated in CI — plus a structured checklist for the criteria only a human can verify.

## Success criteria for v0.1

- The first four rules (R1, R2, R7, R8) run against a pumped widget and return correct findings on the broken example app and zero findings on a clean fixture.
- Core rules are unit-tested with no Flutter dependency.
- The package analyzes clean under `flutter_lints`, is fully documented, and is publishable to pub.dev.
