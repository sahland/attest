# attest

Continuous accessibility-compliance tooling for Flutter.

**attest** runs inside ordinary widget tests, walks the Flutter semantics tree,
detects accessibility violations, maps each one to a specific success criterion
(WCAG 2.1/2.2 and EN 301 549), and gates CI against regressions. Because Flutter
renders to its own canvas, web accessibility tools such as axe-core and
Lighthouse cannot inspect a Flutter app — this fills that gap.

> **Honest framing.** Automated checks catch roughly 30–40% of accessibility
> issues. attest provides automated coverage of machine-checkable criteria plus
> a structured checklist for the rest. It does **not** certify "EAA compliance."

## Quick start

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

One call walks the semantics tree, rasterizes for contrast, re-pumps at enlarged
text sizes, and returns a report where every finding cites a WCAG success
criterion and EN 301 549 clause, anchored to the `file:line` that produced it.

## What it checks

Thirteen rules across three detection methods — tree walk, rasterized pixels,
and re-pump at enlarged text:

- **Names & roles:** interactive-name, image-alt, placeholder-name, field-label,
  ambiguous-name, state-exposed
- **Geometry & reachability:** target-size, focus-trap, focus-order
- **Rendered output:** contrast and non-text (icon) contrast (real pixels),
  text-overflow (reflow at 200%)
- **Structure:** heading-structure

Plus a **CI baseline gate** (fail only on new findings, by stable fingerprint),
**SARIF/HTML/JSON** output, versioned **standard packs** (WCAG 2.1/EN 301 549
v3.2.1 and WCAG 2.2), and a **screen-reader transcript** — the traversal-order
sequence a screen reader would announce, which no other Flutter tool produces.

## Packages

| Package | Description |
| --- | --- |
| [`attest`](packages/attest) | Pure-Dart core: data model, rule engine, TREE rules, reporting, baseline. |
| [`attest_flutter`](packages/attest_flutter) | Flutter test integration: `WidgetTester` extension, RASTER + TEXTSCALE collectors, matchers. |
| [`attest_cli`](packages/attest_cli) | Dart CLI: report aggregation, baseline gate, SARIF/HTML output. |

Dependency direction is one-way: `attest_flutter` and `attest_cli` depend on
`attest`; the core depends on nothing Flutter.

## Working in this repository

This is a [melos](https://melos.invertase.dev) monorepo built on Dart pub
workspaces (Dart >= 3.6).

```sh
dart pub global activate melos   # once
melos bootstrap                  # resolve the workspace
melos run analyze                # static analysis (fatal infos/warnings)
melos run format:check           # formatting check
melos run test                   # all unit, widget and golden tests
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) — the most valuable contributions are
real-world false positives (each one becomes a permanent adversarial fixture)
and new rules, which the [rule contract](context/Stage2/11_RULE_AUTHORING.md)
keeps small and self-contained. Security issues go through
[SECURITY.md](SECURITY.md), never a public issue.

## License

BSD-3-Clause. See [LICENSE](LICENSE).
