# Changelog

All notable changes to this package are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.3.0

### Added

- `attest transcript`: print the screen-reader transcript for each audited
  screen.

## 0.2.0

### Added

- `attest ci`: aggregate the per-screen JSON reports, diff a baseline by
  fingerprint, render text/JSON/SARIF/HTML, and exit non-zero on new findings.
- `attest baseline --update`: accept the current findings as the new baseline.
- `ReportLoader`, `HtmlWriter`, and a documented GitHub Actions workflow.

## 0.1.0

### Added

- Initial package scaffold and command-runner entry point.
