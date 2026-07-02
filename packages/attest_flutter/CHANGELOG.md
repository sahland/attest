# Changelog

All notable changes to this package are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- The snapshot builder captures the developer-assigned
  `SemanticsProperties.identifier`, and the raster collector attaches the
  nearest semantics identifier to each contrast sample, so findings can be
  anchored to an authored, stable id.
- Reference validation of the measurement paths: the contrast pipeline is
  checked end to end against a table of known colour pairs (within 0.1 of
  independently computed WCAG ratios), gradient and disabled-control
  abstention are pinned by test, and the overflow fixture is proven to fit at
  text scale 1.0 and overflow at 2.0.

### Changed

- The public API is frozen for 1.0: `auditAccessibility`, the gate matchers
  and the re-exported core are stable within a major. The plumbing classes
  (`SemanticsSnapshotBuilder`, `RasterCollector`, `TextScaleCollector`) are
  annotated `@experimental` — ordinary tests never need them directly, and
  their signatures may still evolve for `integration_test` support.
- Stated the version-support policy: Flutter ≥ 3.32 is a hard floor (the
  tri-state `flagsCollection` semantics API), with the current and previous
  three stable Flutter releases supported and each new stable tracked within
  one release cycle.

## 0.9.0

### Changed

- Require `attest` 0.9.0 (state-exposed now fires on pairs).

## 0.8.3

### Fixed

- Report the correct tool version. `attestVersion` was stuck at `0.1.0`, so the
  report metadata and SARIF `tool.driver.version` were wrong; it is now kept in
  sync with the package version by a test.

## 0.8.2

### Fixed

- Correct the SDK constraint: the package uses the `SemanticsData.flagsCollection`
  tri-state API, so it requires Flutter >= 3.32.0 (Dart >= 3.8.0). The previous
  `>= 3.27.0` bound was inaccurate and would fail to compile on 3.27–3.31.

## 0.8.1

### Changed

- Source locations now prefer the user's own code: the resolver walks up from
  the creating element and returns the first location outside the Flutter SDK
  and pub packages, so a finding on a wrapped Material control points at where
  the developer used it rather than at framework internals.

## 0.8.0

### Changed

- The audited standard pack comes from `RuleConfig.standard` and is recorded in
  the report metadata. Requires `attest` 0.8.0.

## 0.7.0

### Added

- `auditAccessibility` attaches a screen-reader transcript to the report by
  default (opt out with `transcript: false`). Requires `attest` 0.7.0.

## 0.6.1

### Changed

- Allow (and require) `attest` 0.6.0.

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
