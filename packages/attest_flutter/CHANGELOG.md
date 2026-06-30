# Changelog

All notable changes to this package are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.1.0

### Added

- `SemanticsSnapshotBuilder`, which converts a live Flutter semantics tree into
  the pure-Dart `SemanticsSnapshot` (mapping the 3.x `flagsCollection` API).
- `WidgetTester.auditAccessibility()`, the one-call audit entry point (tree
  rules only).
- The gate matchers `passesAccessibilityGate()`, `hasNoAccessibilityViolations()`
  and `hasNoViolationsForCriterion()`, with grouped, criterion-tagged failure
  output.
