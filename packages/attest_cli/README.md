# attest_cli

The command-line companion for the [**attest**](https://github.com/sahland/attest)
accessibility-compliance toolkit. It aggregates the per-screen JSON reports
emitted by a widget-test run, diffs them against a baseline by fingerprint, and
renders text, JSON, SARIF or HTML.

The CLI consumes the JSON the test run produces; it does **not** pump widgets
itself, which keeps it Flutter-free and fast.

## Commands

```sh
dart pub global activate attest_cli

# Fail the build if the run introduced findings not in the baseline.
attest ci --report-dir build/a11y --baseline .a11y/baseline.json --format text

# Emit SARIF for GitHub/GitLab PR annotations.
attest ci --format sarif --output attest.sarif

# Accept the current findings as the new baseline.
attest baseline --update --report-dir build/a11y --baseline .a11y/baseline.json
```

`attest ci` exits non-zero when the run produces a finding whose fingerprint is
not in the baseline, so it gates a pull request on *new* accessibility issues
without failing on already-accepted ones.

## Producing reports

Have your widget tests write each `AuditReport` as JSON into the report
directory:

```dart
final report = await tester.auditAccessibility(screenName: 'CheckoutScreen');
File('build/a11y/checkout.json').writeAsStringSync(jsonEncode(report.toJson()));
```

## GitHub Actions

```yaml
name: Accessibility
on: [pull_request]

jobs:
  a11y:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter test        # writes reports into build/a11y
      - run: dart pub global activate attest_cli
      - run: attest ci --format sarif --output attest.sarif
      - if: always()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: attest.sarif
```

Commit `.a11y/baseline.json` to the repository; refresh it with
`attest baseline --update` when you deliberately accept a finding.

## Supported versions

Pure Dart, **SDK ≥ 3.6**, no Flutter dependency — activate it globally on any
CI image with a Dart SDK. The toolkit-wide policy: the current and the previous
three stable Flutter releases are supported.

## API stability

The supported interface is the **command line** (`attest ci`, `attest
baseline`, `attest transcript`): commands, flags and exit codes are stable
under semantic versioning. The Dart library under `lib/` is plumbing for the
executable, annotated `@experimental`, and may change in minor releases.

## License

BSD-3-Clause.
