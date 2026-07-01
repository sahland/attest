# Changelog

All notable changes to this package are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.6.0

### Added

- The snapshot builder now records each text node's font size and weight (from
  the render tree), which the heading-structure rule reads.

### Fixed

- Children are captured in the real traversal order (sort keys + geometry) via
  `debugListChildrenInOrder`, not the raw child order, so the focus-order rule
  no longer false-positives on a standard `Scaffold` app bar.

## 0.5.0

### Added

- Findings now carry a source location. The snapshot builder recovers each
  node's originating widget location from the render tree's debug creator (via a
  new `renderRoot` argument), so a failure points at `file:line`. Best-effort:
  it relies on `--track-widget-creation` (on by default under `flutter test`).

## 0.4.0

### Added

- `RasterCollector` and the `contrast` flag on `auditAccessibility`: the screen
  is rasterized and each text node's contrast against its real background is
  measured for the contrast rule. Requires `attest` 0.4.0.

## 0.3.0

### Added

- `TextScaleCollector` and the `textScales` parameter on `auditAccessibility`:
  the screen is re-pumped at enlarged text sizes and layout overflow is captured
  into the snapshot for the text-overflow rule. Requires `attest` 0.3.0.

## 0.2.0

### Changed

- The snapshot builder now resolves node bounds to logical pixels (dividing the
  accumulated physical rect by the view's device pixel ratio), so the geometry
  rules see real sizes. Requires `attest` 0.2.0.

## 0.1.0

### Added

- `SemanticsSnapshotBuilder`, which converts a live Flutter semantics tree into
  the pure-Dart `SemanticsSnapshot` (mapping the 3.x `flagsCollection` API).
- `WidgetTester.auditAccessibility()`, the one-call audit entry point (tree
  rules only).
- The gate matchers `passesAccessibilityGate()`, `hasNoAccessibilityViolations()`
  and `hasNoViolationsForCriterion()`, with grouped, criterion-tagged failure
  output.
