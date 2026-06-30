/// Programmatic entry point for the `a11y_audit` command-line tool.
///
/// The CLI aggregates the per-screen JSON reports emitted by a widget-test run,
/// diffs them against a baseline by fingerprint, and renders JSON, SARIF and
/// HTML output. It never pumps widgets itself, which keeps it Flutter-free and
/// fast.
///
/// This barrel is the only supported entry point. The command implementations
/// are added as they are built (see the roadmap, M6 onwards).
library;
