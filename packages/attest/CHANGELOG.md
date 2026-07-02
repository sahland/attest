# Changelog

All notable changes to this package are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- `SemanticsNodeData.identifier` and `Finding.identifier`, carrying the
  developer-assigned semantics identifier (`SemanticsProperties.identifier`). A
  finding resolves to the offending node's identifier, or its nearest ancestor's.
- `ContrastSample.identifier`, so a contrast finding is anchored to the sampled
  text node the same way tree-rule findings are.
- The validation-corpus API (`package:attest/corpus.dart`): `CorpusCase`,
  `ExpectedFinding` and `CorpusCategory`, the labelled ground-truth types the
  precision/recall harness measures each rule against.
- `MetricsHarness` and `CorpusMetrics`: run the corpus, compute per-rule
  precision, recall and false-positive-on-clean rate, and evaluate a CI gate
  (deterministic precision must be 1.0, zero false positives on clean cases,
  heuristics must meet a declared threshold, and recall must not regress against
  a committed baseline).
- `declaredHeuristicPrecision`: an explicit precision bar (0.9) for each of the
  four heuristic rules, enforced by the metrics gate. A contract test verifies
  every heuristic declares a bar, tags its findings `heuristic`, and is
  suppressible in one line via `RuleConfig.disabledRules`.
- Determinism and performance guarantees are now regression-tested: identical
  input produces byte-identical output regardless of rule registration order, a
  pure layout translation leaves every fingerprint unchanged while a genuine
  violation change moves exactly one, and a 2000-node screen must audit within
  an explicit per-screen time budget.

### Changed

- The public API is frozen for 1.0. Everything exported from
  `package:attest/attest.dart` is stable within a major, with two documented
  exceptions annotated `@experimental` (free to change in minors, always
  changelogged): the validation-corpus library (`package:attest/corpus.dart`)
  and `TranscriptGenerator`, whose announcement wording awaits cross-validation
  against real screen readers.
- Stated the version-support policy: Dart SDK ≥ 3.6 (a tooling floor, not a
  language-feature requirement — documented in the pubspec), and toolkit-wide
  support for the current and previous three stable Flutter releases.

## 0.9.0

### Changed

- `attest/state-exposed` now fires on a group of two or more custom controls
  (down from three), catching small segmented/toggle pairs that expose no
  selected state.

## 0.8.0

### Added

- Versioned standard packs: `Standard` (`en301549_v3_2_1`, `wcag22`) and
  `RuleConfig.standard`. The engine runs a rule only when its criterion belongs
  to the selected pack, so `attest/target-size` (WCAG 2.5.8) is active only under
  `wcag22`.

## 0.7.0

### Added

- `TranscriptGenerator`, which turns a snapshot into the screen-reader
  announcement sequence, and an `AuditReport.transcript` field to carry it.

## 0.6.0

### Added

- Report layer: `Baseline` (accepted-fingerprint set with JSON), `BaselineGate`
  (new/known/resolved diff), and `SarifWriter` (SARIF 2.1.0 output).

## 0.5.0

### Added

- Three heuristic rules, each tagged `heuristic` and suppressible:
  `attest/heading-structure` (1.3.1), `attest/focus-order` (2.4.3) and
  `attest/state-exposed` (4.1.2).
- `RuleConfig.disabledRules` to mute individual rules across a run.

## 0.4.0

### Added

- `attest/contrast` rule (WCAG 1.4.3): 4.5:1 for normal text, 3:1 for large,
  disabled controls exempt, borderline ratios downgraded to a warning.
- `SemanticsSnapshot.copyWith`.

### Changed

- `ContrastSample` now carries the label, bounds, font size, weight and disabled
  state so the rule is self-contained.

## 0.3.0

### Added

- `attest/text-overflow` rule (WCAG 1.4.4) reading the text-scale observations,
  and the `Resize Text` criterion.

## 0.2.0

### Added

- Three geometry and reachability rules: `attest/target-size` (WCAG 2.5.8, with
  a configurable platform/WCAG-minimum threshold), `attest/focus-trap` (2.1.1),
  and the heuristic `attest/ambiguous-name` (2.4.6).
- `TargetSizeMode` and the `targetSizeMode`/`platformTargetSize` options on
  `RuleConfig`.

## 0.1.0

### Added

- Serializable, Flutter-free data model: `SemanticsSnapshot`, `SemanticsNodeData`,
  `Finding`, `Criterion`, `AuditReport` and friends, all with value equality and
  JSON round-trip.
- `Rule` interface, `RuleEngine`, `RuleConfig`/`RuleContext`, and a stable,
  coordinate-free `Fingerprinter` for baseline diffing.
- The first four tree-walking rules: `attest/interactive-name`,
  `attest/image-alt`, `attest/placeholder-name` and `attest/field-label`, each
  bound to a WCAG and EN 301 549 criterion.
