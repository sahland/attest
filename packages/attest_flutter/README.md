# attest_flutter

**Accessibility testing for Flutter — in your widget tests, gated in CI.**

[![pub package](https://img.shields.io/pub/v/attest_flutter.svg)](https://pub.dev/packages/attest_flutter)
[![pub points](https://img.shields.io/pub/points/attest_flutter)](https://pub.dev/packages/attest_flutter/score)
[![likes](https://img.shields.io/pub/likes/attest_flutter)](https://pub.dev/packages/attest_flutter/score)
[![license: BSD-3-Clause](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE)

Web accessibility tools like axe-core, Lighthouse and WAVE can't test a Flutter
app — Flutter paints to a canvas with no DOM, so to those tools your whole app
is one anonymous `<canvas>`. `attest_flutter` audits accessibility from inside an
ordinary `WidgetTester`: it walks the live semantics tree, measures real colour
contrast from rendered pixels, catches layout overflow at 200% text size, and
maps every finding to a **WCAG** success criterion and **EN 301 549** clause,
pointed at the `file:line` that produced it. It gates CI on new issues and can
print the transcript a screen reader (TalkBack / VoiceOver) would announce.

> **Honest framing.** Automated checks catch roughly a third of accessibility
> issues — the machine-checkable ones. This does **not** make your app
> WCAG- or EAA-compliant, and it complements real screen-reader testing rather
> than replacing it. It gives you automated coverage of the checkable part plus
> a structured checklist for the rest.

## Install

```sh
flutter pub add dev:attest_flutter
```

## Quick start

Audit any pumped screen from a widget test:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:attest_flutter/attest_flutter.dart';

void main() {
  testWidgets('CheckoutScreen is accessible', (tester) async {
    await tester.pumpWidget(const MyApp(home: CheckoutScreen()));

    final report = await tester.auditAccessibility();

    expect(report, passesAccessibilityGate());
  });
}
```

When the gate fails, the message is grouped and source-located — one entry per
finding, each citing its WCAG criterion and EN 301 549 clause with a concrete
fix and the `file:line` to change.

## What it checks

Twelve rules across three detection methods that source-level linters can't do:

- **Names & roles** — unlabeled buttons, images with no alt text, form fields
  with no label, generic "Button" labels, duplicate/ambiguous names.
- **Rendered output** — real text **contrast** measured from the rasterized
  screen, and layout **overflow / reflow** when the system font is scaled to
  200%.
- **Reachability & structure** — touch **target size**, interactive elements
  hidden from assistive technology, illogical focus order, missing heading
  semantics.

Every finding cites WCAG 2.1 / 2.2 and the matching EN 301 549 clause, so the
output maps to the standard an auditor will actually ask about.

## Fail CI on new issues

Write each report to JSON, then let the [`attest_cli`](https://pub.dev/packages/attest_cli)
`ci` command diff a baseline by fingerprint and fail only on **new** findings —
like a coverage gate. It emits **SARIF** for GitHub's Problems panel and HTML
for humans. See the [CLI README](https://pub.dev/packages/attest_cli) for a
ready-made GitHub Actions workflow.

## Screen-reader transcript

`auditAccessibility()` also returns the sequence a screen reader would announce,
in traversal order — the fastest way to hear what your screen sounds like
without a device:

```dart
final report = await tester.auditAccessibility();
print(report.transcript); // [Your orders, heading, Pay, button, Email, edit box, …]
```

## FAQ

### How do I test accessibility in a Flutter app?

Pump the screen in a widget test and call `tester.auditAccessibility()`, then
assert `passesAccessibilityGate()`. It runs on the flutter_tester — no device,
no real screen reader needed for the automated pass.

### Why can't I use axe-core, Lighthouse or Accessibility Scanner for this?

Those read the DOM (web) or the Android view hierarchy. Flutter renders its own
widgets to a canvas, so they see one opaque surface. attest reads Flutter's
semantics tree directly — the same data TalkBack and VoiceOver consume.

### Does this make my app WCAG or EAA compliant?

No. No automated tool can. It covers the machine-checkable criteria and hands
you a checklist for the rest (meaningful alt text, media captions, real
assistive-technology testing).

### How do I silence a false positive?

Mute any rule in one line via `RuleConfig(disabledRules: {'attest/heading-structure'})`.
Heuristic rules ship as warnings for exactly this reason.

## Related packages

- [`attest`](https://pub.dev/packages/attest) — the pure-Dart rule engine and
  data model (no Flutter dependency).
- [`attest_cli`](https://pub.dev/packages/attest_cli) — the CI baseline gate and
  SARIF / HTML / JSON reporter.

## Status

Early (`0.9.x`); the API may still change before 1.0. Feedback — especially
false positives from real apps — is very welcome on the
[issue tracker](https://github.com/sahland/attest/issues).

## License

BSD-3-Clause.
