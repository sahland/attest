/// Flutter test integration for **attest**.
///
/// Provides the `WidgetTester` accessibility-audit extension, the raster and
/// text-scale collectors that enrich a [SemanticsSnapshot] with observations a
/// pure-Dart run cannot produce, and the gate matchers used in widget tests.
///
/// This barrel is the only supported entry point. Import only
/// `package:attest_flutter/attest_flutter.dart`.
library;

// Re-export the core so a test file needs a single import.
export 'package:attest/attest.dart';

export 'src/audit_extension.dart';
export 'src/audit_flow.dart';
export 'src/matchers.dart';
export 'src/raster_collector.dart';
export 'src/snapshot_builder.dart';
export 'src/text_scale_collector.dart';
