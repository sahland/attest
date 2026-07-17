# Changelog

All notable changes to this package are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.6.0 - 2026-07-15

### Added

- `attest ci --history <path>`: append each run to a JSON trend log and report
  how the finding count moved since the previous run — a `Trend:` line in the
  text output and a coloured banner in the HTML report (`▼ 2 since last run`).
  The log is length-capped and safe to commit, so a project can watch its
  accessibility debt shrink over time. Requires `attest` 1.11.0.

## 1.5.0 - 2026-07-15

### Added

- The HTML report renders a finding's `codeExample` as a syntax-styled code
  block, and the text output prints it indented under the fix, so the
  before/after remedy is right next to the violation. Requires `attest` 1.10.0.

## 1.4.0 - 2026-07-15

### Added

- Every finding in the text and HTML output now links to the W3C "Understanding"
  page for its criterion — a "Learn:" line in the terminal, a "Understanding … →"
  link in the HTML report — so a developer can jump straight to the authoritative
  guidance. Requires `attest` 1.9.0.

## 1.3.0 - 2026-07-02

### Added

- `attest ci --format conformance`: emit the machine-readable conformance
  document (clause-by-clause coverage plus mapped findings). Requires `attest`
  1.4.0.

## 1.2.0 - 2026-07-02

### Added

- The HTML report now appends a generated **manual-review checklist** built from
  the coverage matrix: every criterion attest cannot fully verify, with its
  guidance, as a checklist item. The report is a complete audit trail rather
  than an implied all-clear, and it renders even when there are no automated
  findings.
- `attest coverage` text output now shows each criterion's guidance note.
  Requires `attest` 1.3.0.

## 1.1.0 - 2026-07-02

### Added

- `attest coverage`: print the coverage matrix for a standard pack (`text` or
  `json`) — which WCAG clauses attest checks automatically, partially, or leaves
  to human review. Requires `attest` 1.2.0.

## 1.0.0 - 2026-07-02

First stable release. Requires `attest` 1.0.0.

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
