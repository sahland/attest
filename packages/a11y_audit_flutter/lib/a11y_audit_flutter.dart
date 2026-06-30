/// Flutter test integration for `a11y_audit`.
///
/// Provides the `WidgetTester` accessibility-audit extension, the raster and
/// text-scale collectors that enrich a [SemanticsSnapshot] with observations a
/// pure-Dart run cannot produce, and the gate matchers used in widget tests.
///
/// This barrel is the only supported entry point. Import only
/// `package:a11y_audit_flutter/a11y_audit_flutter.dart`.
library;

// Re-export the core so a test file needs a single import.
export 'package:a11y_audit/a11y_audit.dart';

// Flutter-facing API is exported here as it is built out (see roadmap M1+).
// Intentionally minimal during the M0 scaffold.
