import 'package:attest/attest.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'raster_collector.dart';
import 'snapshot_builder.dart';
import 'text_scale_collector.dart';

/// The version of attest reported in [AuditMeta.toolVersion].
///
/// Kept in sync with the package version by a test; see `version_test.dart`.
const String attestVersion = '1.4.0';

/// Accessibility auditing for [WidgetTester].
extension AccessibilityAudit on WidgetTester {
  /// Audits the currently pumped screen and returns an [AuditReport].
  ///
  /// This is the one obvious entry point. With no arguments it builds a snapshot
  /// of the live semantics tree, runs the bundled rules against EN 301 549, and
  /// gates on [Severity.error]:
  ///
  /// ```dart
  /// await tester.pumpWidget(const MyApp(home: CheckoutScreen()));
  /// final report = await tester.auditAccessibility();
  /// expect(report, passesAccessibilityGate());
  /// ```
  ///
  /// Pass [screenName] to label the report, [engine] to supply a custom rule
  /// set, [config] to tune the rules, [gateSeverity] to change which findings
  /// fail the gate, and [textScales] to choose the system text sizes the
  /// overflow check re-pumps at (1.0 is the as-pumped baseline and is skipped by
  /// the collector). Pass `const [1.0]` to disable the text-scale pass. Set
  /// [contrast] to `false` to skip the (more expensive) raster contrast pass,
  /// and [transcript] to `false` to skip attaching the screen-reader transcript.
  Future<AuditReport> auditAccessibility({
    String screenName = 'screen',
    RuleEngine? engine,
    RuleConfig config = const RuleConfig(),
    Severity gateSeverity = Severity.error,
    List<double> textScales = const [1.0, 1.3, 2.0],
    bool contrast = true,
    bool transcript = true,
  }) async {
    final handle = ensureSemantics();
    await pump();
    try {
      final (root, devicePixelRatio, renderRoot) = _rootSemanticsView();
      var snapshot = const SemanticsSnapshotBuilder().build(
        root,
        devicePixelRatio: devicePixelRatio,
        renderRoot: renderRoot,
      );

      if (contrast) {
        final samples = await const RasterCollector().collect(this);
        snapshot = snapshot.copyWith(contrastSamples: samples);
      }

      if (textScales.any((scale) => scale != 1.0)) {
        final observations = await const TextScaleCollector().collect(
          this,
          textScales,
        );
        snapshot = snapshot.copyWith(textScaleObservations: observations);
      }

      var report = (engine ?? RuleEngine.standard()).run(
        snapshot,
        meta: AuditMeta(
          screenName: screenName,
          standard: config.standard.name,
          toolVersion: attestVersion,
          timestamp: DateTime.now().toUtc(),
        ),
        config: config,
        gateSeverity: gateSeverity,
      );
      if (transcript) {
        report = report.copyWith(
          // The generator is our own experimental API; consuming it here is
          // deliberate — the audit entry point itself stays stable.
          // ignore: experimental_member_use
          transcript: const TranscriptGenerator().generate(snapshot),
        );
      }
      return report;
    } finally {
      handle.dispose();
    }
  }

  (SemanticsNode, double, RenderObject) _rootSemanticsView() {
    for (final view in binding.renderViews) {
      final root = view.owner?.semanticsOwner?.rootSemanticsNode;
      if (root != null) {
        return (root, view.flutterView.devicePixelRatio, view);
      }
    }
    throw StateError(
      'No semantics tree is available. Pump a widget before calling '
      'auditAccessibility().',
    );
  }
}
