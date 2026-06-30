# attest

The pure-Dart core of the [**attest**](https://github.com/sahland/attest)
accessibility-compliance toolkit for Flutter: the data model, the rule engine,
the tree-walking rules, report aggregation and baseline diffing.

> **Honest framing.** Automated checks catch roughly 30–40% of accessibility
> issues. This package provides automated coverage of machine-checkable
> criteria plus a structured checklist for the rest. It does **not** certify
> "EAA compliance."

This package has no Flutter dependency. Every rule is a pure function over a
serializable `SemanticsSnapshot`, which makes rules fast and exhaustively
unit-testable. The Flutter-facing helpers (the `WidgetTester` extension and the
raster/text-scale collectors) live in
[`attest_flutter`](https://pub.dev/packages/attest_flutter).

## Status

Early development. The public API is not yet stable.

## License

BSD-3-Clause.
