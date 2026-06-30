# a11y_audit_cli

The command-line companion for the
[`a11y_audit`](https://github.com/a11y-audit/a11y_audit) accessibility-compliance
toolkit. It aggregates the per-screen JSON reports emitted by a widget-test run,
diffs them against a baseline by fingerprint, and emits JSON, SARIF and HTML.

The CLI consumes the JSON the test run produces; it does **not** pump widgets
itself, which keeps it Flutter-free and fast.

```sh
dart pub global activate a11y_audit_cli

a11y_audit ci --baseline .a11y/baseline.json --format sarif
a11y_audit baseline --update
a11y_audit transcript --report-dir build/a11y
```

> The commands above are the target surface; they are being built out (see the
> roadmap).

## Status

Early development. The command surface is not yet stable.

## License

BSD-3-Clause.
