# a11y_audit

The pure-Dart core of the [`a11y_audit`](https://github.com/a11y-audit/a11y_audit)
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
[`a11y_audit_flutter`](https://pub.dev/packages/a11y_audit_flutter).

## Status

Early development. The public API is not yet stable.

## License

BSD-3-Clause.
