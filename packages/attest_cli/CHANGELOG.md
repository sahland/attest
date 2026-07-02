# Changelog

All notable changes to this package are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed

- Declared the stability contract: the supported interface is the command line
  (commands, flags, exit codes), stable under semantic versioning. The Dart
  library surface is plumbing for the executable and is now annotated
  `@experimental`.
- Stated the version-support policy: Dart SDK ≥ 3.6, no Flutter dependency,
  and toolkit-wide support for the current and previous three stable Flutter
  releases.

## 0.5.0

### Changed

- Require `attest` 0.9.0.

## 0.4.0

### Changed

- Require `attest` 0.8.0 (standard packs).

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
