# 02 — API Design

The library succeeds or fails on ergonomics. A first-time user must get value from one obvious call with zero configuration, and power users must be able to tune everything without fighting the defaults. Follow the Flutter team's own API style: sensible defaults, named parameters, progressive disclosure, no surprises.

## Design principles

1. **One obvious entry point.** `tester.auditAccessibility()` is *the* call. Everything else is optional.
2. **Sensible defaults.** Zero-config = audit against EN 301 549 v3.2.1, gate on `error`, text scales `[1.0, 1.3, 2.0]`.
3. **Progressive disclosure.** Defaults are great; an optional `AuditConfig` exposes thresholds, rule toggles, ignores, and the target-size mode.
4. **No hidden global state.** Config is passed in or read from a single discoverable file, never from mutable globals.
5. **Fail loud, fail readable.** A gate failure prints a grouped, criterion-tagged, source-located summary — not a stack trace.

## Primary developer-facing API (the happy path)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:a11y_audit_flutter/a11y_audit_flutter.dart';

void main() {
  testWidgets('CheckoutScreen is accessible', (tester) async {
    await tester.pumpWidget(const MyApp(home: CheckoutScreen()));

    final report = await tester.auditAccessibility();

    expect(report, passesAccessibilityGate());
  });
}
```

That is the entire zero-config experience. When it fails, the output reads:

```
CheckoutScreen — 2 accessibility violations (gate: error)

  ✗ [error] a11y/interactive-name — WCAG 4.1.2 (A) / EN 301 549 §11.5.2.5
    IconButton has no accessible name; screen readers announce only "button".
    lib/checkout/pay_button.dart:42
    Fix: wrap in Semantics(label: 'Pay', button: true) or use IconButton(tooltip: ...).

  ✗ [error] a11y/contrast — WCAG 1.4.3 (AA) / EN 301 549 §11.5.2.4
    Text contrast 3.1:1 (needs ≥ 4.5:1).
    lib/checkout/total.dart:88
    Fix: darken the text colour or lighten the background.
```

## Configuration (progressive disclosure)

```dart
final report = await tester.auditAccessibility(
  config: AuditConfig(
    standard: Standard.en301549_v3_2_1, // or .wcag22
    gateSeverity: Severity.error,        // findings >= this fail the gate
    textScales: const [1.0, 1.5],
    targetSizeMode: TargetSizeMode.platform, // .platform (48/44) | .wcagMinimum (24)
    rules: RuleSelection.allExcept({'a11y/heading-structure'}), // or .only({...})
    ignore: const [
      Ignore.rule('a11y/target-size', whereLabel: 'calendar-day'),
    ],
  ),
);
```

`AuditConfig` has a `const` constructor and every parameter defaults, so partial configuration is natural. A project-level default can live in `a11y_audit.yaml` at the repo root and is merged under any inline config.

## Inline ignores (source-level)

Mirror the Dart analyzer's ergonomics so it feels native:

```dart
// a11y-ignore: a11y/target-size — decorative density toggle, spacing compensates
GestureDetector(onTap: ..., child: ...)
```

The snapshot builder reads these from the widget's source span (via `creator`) and the engine suppresses matching findings. Every ignore requires a trailing reason after `—`; an ignore without a reason is itself reported as `info` (so ignores stay honest and reviewable).

## The matcher

```dart
/// Passes when the report has no finding at or above the configured gate severity.
Matcher passesAccessibilityGate();

/// Stricter variants for fine-grained tests.
Matcher hasNoAccessibilityViolations();          // zero findings at all
Matcher hasNoViolationsForCriterion(String wcag); // e.g. '1.4.3'
```

Matchers produce the grouped, readable failure description above — never a raw object dump.

## CLI surface

```
a11y_audit ci [--baseline .a11y/baseline.json] [--format sarif|json|html] [--report-dir build/a11y]
    Aggregate per-screen JSON reports, diff the baseline, exit non-zero on new findings.

a11y_audit baseline --update [--report-dir build/a11y]
    Accept the current findings as the new baseline.

a11y_audit transcript --report-dir build/a11y
    Print the screen-reader transcript for each audited screen.
```

The CLI consumes the JSON the test run emits; it does not pump widgets itself. Keep this separation — it keeps the CLI Flutter-free and fast.

## Naming conventions

- Rule IDs: `a11y/<kebab-case>` — e.g. `a11y/interactive-name`, `a11y/contrast`, `a11y/target-size`.
- Public types: no `A11y` prefix soup. Prefer `AuditReport`, `AuditConfig`, `Finding`, `Rule`. The package name already namespaces them.
- Enums use lowerCamel values (`Severity.error`), matching Dart style.
- Boolean parameters are avoided in favour of enums when a third state is plausible (`TargetSizeMode`, not `bool strict`).

## API stability

Everything under `lib/` is public API and bound by semver. Anything experimental ships under an explicitly documented `@experimental` annotation (from `package:meta`) and may change in minor versions. Internal code lives in `lib/src/` and is never exported directly.
