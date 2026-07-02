# attest — GitHub Action

Gate a Flutter pull request on **new** accessibility findings, like a coverage
gate. It activates [`attest_cli`](https://pub.dev/packages/attest_cli),
aggregates the per-screen JSON reports your widget tests wrote, diffs them
against a committed baseline by fingerprint, and fails the job only on findings
that are not already accepted.

## Prerequisites

1. Your widget tests audit screens with
   [`attest_flutter`](https://pub.dev/packages/attest_flutter) and write each
   report as JSON into a directory (default `build/a11y`).
2. Dart/Flutter is set up in the workflow (e.g. `subosito/flutter-action`), so
   the `dart` command is available.
3. A baseline is committed at `.a11y/baseline.json` (create it once with
   `attest baseline --update`).

## Usage

```yaml
name: Accessibility
on: [pull_request]

jobs:
  a11y:
    runs-on: ubuntu-latest
    permissions:
      security-events: write # only needed to upload SARIF
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - run: flutter test # your tests write reports into build/a11y

      - uses: sahland/attest/action@v1
        with:
          format: sarif
          output: attest.sarif

      - if: always()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: attest.sarif
```

The `attest ci` step exits non-zero when a new finding appears, which fails the
job. The `if: always()` upload still runs so the SARIF annotations show up on
the pull request either way.

## Inputs

| Input | Default | Description |
| --- | --- | --- |
| `report-dir` | `build/a11y` | Directory of per-screen JSON reports. |
| `baseline` | `.a11y/baseline.json` | Committed baseline of accepted findings. |
| `format` | `sarif` | `text`, `json`, `sarif` or `html`. |
| `output` | `attest.sarif` | Where to write the rendered report. |
| `version` | latest | Version constraint for `attest_cli`, e.g. `^1.1.0`. |

## Pinning

Pin to a major with `@v1`, or to an exact release tag for full reproducibility.
