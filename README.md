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

## License

BSD-3-Clause. See [LICENSE](LICENSE).
