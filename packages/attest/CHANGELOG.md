# Changelog

All notable changes to this package are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
