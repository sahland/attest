# 05 — Testing strategy

An accessibility auditor that is itself buggy is worse than useless — it gives false confidence about a legal obligation. So this package holds itself to a higher testing bar than the apps it audits.

## The core principle

Because rules are pure functions over `SemanticsSnapshot`, **the bulk of testing needs no Flutter at all.** For every rule there are at least two unit tests:

- a **violating fixture** — a hand-built `SemanticsSnapshot` that *must* produce exactly the expected finding(s);
- a **clean fixture** — a snapshot that *must* produce nothing.

This makes rule tests fast, deterministic, and exhaustive. Build a small fixture DSL so snapshots read clearly:

```dart
final snapshot = snap(
  node(
    flags: {isButton},
    actions: {tap},
    label: '', // ← the violation
    bounds: rect(0, 0, 48, 48),
  ),
);

test('flags an unnamed button', () {
  final findings = InteractiveNameRule().evaluate(snapshot, ctx());
  expect(findings, hasFinding('a11y/interactive-name', wcag: '4.1.2'));
});

test('accepts a named button', () {
  final snapshot = snap(node(flags: {isButton}, actions: {tap}, label: 'Pay', bounds: rect(0,0,48,48)));
  expect(InteractiveNameRule().evaluate(snapshot, ctx()), isEmpty);
});
```

Maintain a coverage matrix: every rule × {violating, clean, edge cases}. Edge cases worth explicit tests: disabled controls (contrast exemption), decorative-but-excluded images, ignore directives, borderline contrast ratios, RTL focus order.

## Flutter-layer tests (the thin part)

Only the Flutter-specific glue needs a `WidgetTester`:

- **`SemanticsSnapshotBuilder`** — pump known widgets, assert the produced snapshot has the right labels/flags/bounds/source locations. This is where we verify that real Flutter widgets map correctly into the data model.
- **RASTER collector** — golden/pixel tests: pump text on known backgrounds, assert the computed contrast ratio matches expected within tolerance.
- **TEXTSCALE collector** — pump a deliberately fragile layout, assert an overflow observation is captured at scale 2.0 and absent at 1.0.
- **Matcher output** — assert the failure description is the grouped, criterion-tagged, source-located text (not an object dump). The failure *message* is part of the product; test it.

## The dogfood example app

`example/` is an app with **intentional, catalogued accessibility defects** — one per rule, plus a few clean screens. It serves three purposes: a living demo, a fixture for end-to-end tests, and a CI canary. A test asserts the audit finds exactly the catalogued defects and nothing on the clean screens. If a code change makes the example over- or under-report, CI fails.

## CLI & baseline tests

- Baseline diffing is pure set arithmetic over fingerprints — unit-test it directly: given a baseline and a current report, assert the computed "new findings" set.
- **Fingerprint stability test:** generate a snapshot, mutate only coordinates/layout, and assert fingerprints are unchanged. Then mutate the actual violation and assert the fingerprint changes. This guards the single most important property of the baseline gate.
- SARIF output: validate against the SARIF schema so PR annotations never silently break.

## Coverage & gates

- Target ≥ 95% line coverage on the core package (it is pure logic; there is no excuse for less).
- The Flutter package will be lower due to rendering glue; cover the collectors' logic, accept that pixel paths are partly golden-tested.
- CI runs `test --coverage` and fails if coverage drops below the threshold.

## What NOT to do

- Do not test rules through the `WidgetTester` when a pure snapshot fixture suffices — it is slower and conflates two concerns.
- Do not assert on coordinates in fingerprint tests (that would re-introduce the brittleness the fingerprint design exists to avoid).
- Do not skip the clean-fixture test for any rule; a rule that never stays silent is a rule that will drown users in false positives.
