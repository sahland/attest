# Changelog

All notable changes to this package are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
