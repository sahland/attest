# 01 — Architecture

## Guiding idea

The single most important design decision: **the rule engine never touches live Flutter types.** It operates on a plain, serializable `SemanticsSnapshot`. The Flutter-facing package converts the live semantics tree (and raster/text-scale observations) into that snapshot, then hands it to the core. Consequences:

- Every rule is a pure function over data → unit-testable with hand-built fixtures, no `WidgetTester`, milliseconds per test.
- The snapshot is serializable → a test run can dump JSON, and the CLI can do baseline diffing and reporting completely decoupled from Flutter.
- New detection methods (raster, text-scale) just enrich the snapshot; rules stay unchanged.

## Packages (melos monorepo)

### `a11y_audit` (pure Dart core)
Depends only on `meta` and `collection`. Contains:
- The data model (`SemanticsSnapshot`, `SemanticsNodeData`, `Finding`, `Criterion`, `AuditReport`).
- The `Rule` abstraction and the rule registry / packs.
- All **TREE** rules (operate purely on the snapshot).
- Report aggregation, JSON + SARIF serialization, baseline loading/diffing, fingerprinting.

### `a11y_audit_flutter` (Flutter test integration)
Depends on `flutter`, `flutter_test`, and `a11y_audit`. Contains:
- `SemanticsSnapshotBuilder` — converts a live `SemanticsNode` tree into a `SemanticsSnapshot`, pulling source locations from `debugCreator`.
- The **RASTER** collector (contrast: rasterize via `RepaintBoundary.toImage`, sample text vs background pixels).
- The **TEXTSCALE** collector (re-pump under `TextScaler.linear(n)`, capture overflow errors).
- The `WidgetTester.auditAccessibility(...)` extension (the main developer entry point).
- The `passesAccessibilityGate()` matcher.

> Note: this package depends on `flutter_test` in `dependencies` (not `dev_dependencies`), because it *provides* test helpers. This is intentional and correct for a test-helper package.

### `a11y_audit_cli` (Dart CLI)
Depends on `a11y_audit` and `args`. Contains:
- `a11y_audit ci` — reads the JSON reports emitted by the test run, diffs against `.a11y/baseline.json`, exits non-zero on new violations.
- `a11y_audit baseline --update` — rewrites the baseline.
- Report rendering: JSON, SARIF (for GitHub/GitLab PR annotations), HTML (for humans).

## Data model (core)

```dart
/// A serializable, Flutter-free snapshot of one screen's semantics + observations.
class SemanticsSnapshot {
  final SemanticsNodeData root;
  final List<TextScaleObservation> textScaleObservations; // from TEXTSCALE
  final List<ContrastSample> contrastSamples;             // from RASTER
}

class SemanticsNodeData {
  final int id;
  final String label;
  final String value;
  final String hint;
  final String tooltip;
  final Set<SemanticsFlagData> flags;     // isButton, isImage, isTextField, isHeader, isHidden, isEnabled, ...
  final Set<SemanticsActionData> actions; // tap, longPress, increase, ...
  final RectData bounds;                   // GLOBAL coordinates
  final TextDirectionData textDirection;
  final List<SemanticsNodeData> childrenInTraversalOrder;
  final SourceLocation? creator;           // file:line, from debugCreator
  final TextStyleData? textStyle;          // font size/weight, when the node is text
}

class Finding {
  final String ruleId;            // 'a11y/interactive-name'
  final Criterion criterion;
  final Severity severity;        // error | warning | info
  final Confidence confidence;    // deterministic | heuristic
  final SourceLocation? location;
  final RectData bounds;
  final String message;
  final String suggestion;
  final String fingerprint;       // stable across runs; see below
}

class Criterion {
  final String wcag;        // '1.4.3'
  final String wcagLevel;   // 'A' | 'AA'
  final String en301549;    // '11.5.2.4'
  final String title;       // 'Contrast (Minimum)'
}

class AuditReport {
  final List<Finding> findings;
  final AuditMeta meta; // screen name, standard pack, timestamp, tool version
  bool get passes; // no findings at or above the configured gate severity
}
```

All model classes are immutable (`final` fields, `const` constructors where possible), implement value equality, and have `toJson`/`fromJson`.

## The `Rule` abstraction

```dart
abstract interface class Rule {
  String get id;                 // 'a11y/interactive-name'
  Criterion get criterion;
  Severity get defaultSeverity;
  Confidence get confidence;

  /// Pure: inspect the snapshot, yield zero or more findings.
  Iterable<Finding> evaluate(SemanticsSnapshot snapshot, RuleContext ctx);
}
```

`RuleContext` carries configuration (thresholds, ignore lists, target-size mode). Rules must be stateless and deterministic given the same snapshot + context.

## Detection methods

| Method | Lives in | How |
|---|---|---|
| **TREE** | core, pure | walk `SemanticsNodeData` tree |
| **RASTER** | `_flutter` collector → fills `contrastSamples` | rasterize, sample pixels, compute WCAG luminance/contrast |
| **TEXTSCALE** | `_flutter` collector → fills `textScaleObservations` | re-pump at scale 1.3 / 2.0, capture overflow + text clipping |

The core rules read whichever fields the collectors populated. If a snapshot has no `contrastSamples` (e.g. a pure-Dart unit test), the contrast rule simply yields nothing — graceful degradation, no crash.

## Engine flow

1. Test pumps a screen and calls `tester.auditAccessibility(...)`.
2. The Flutter package builds the `SemanticsSnapshot` (TREE) and runs the RASTER + TEXTSCALE collectors to enrich it.
3. The core `RuleEngine` runs every enabled rule over the snapshot, applies severity/ignore config, and produces an `AuditReport`.
4. The matcher asserts `report.passes`; the report is also written to `build/a11y/<screen>.json`.
5. In CI, `a11y_audit ci` aggregates those JSON files, diffs the baseline by `fingerprint`, and emits SARIF/HTML.

## Fingerprint design (critical for the baseline gate)

The fingerprint must be **stable across runs** (so an accepted finding stays accepted) but **change on a genuine regression**. Compose it from: `ruleId` + `criterion.wcag` + a normalized widget path (node types from root, not `hashCode`s) + a short hash of the offending label/role. **Do not include coordinates** — a layout shift must not masquerade as a new violation. Baseline diffing is set arithmetic over fingerprints: `new = current − baseline`.

## Output formats

- **JSON** — canonical, machine-readable, the format tests emit and the CLI consumes.
- **SARIF** — so GitHub/GitLab render findings as inline PR annotations.
- **HTML** — human-facing summary grouped by criterion and severity.
- **Screen-reader transcript** — plain text, the traversal-order sequence of announcements; printed to CI logs.
