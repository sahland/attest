import 'package:attest/attest.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'snapshot_builder.dart';
import 'text_scale_collector.dart';

/// The version of attest reported in [AuditMeta.toolVersion].
const String attestVersion = '0.1.0';

/// The default standard pack the audit runs against.
const String _defaultStandard = 'en301549_v3_2_1';

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
  /// the collector). Pass `const [1.0]` to disable the text-scale pass.
  Future<AuditReport> auditAccessibility({
    String screenName = 'screen',
    RuleEngine? engine,
    RuleConfig config = const RuleConfig(),
    Severity gateSeverity = Severity.error,
    List<double> textScales = const [1.0, 1.3, 2.0],
  }) async {
    final handle = ensureSemantics();
    await pump();
    try {
      final (root, devicePixelRatio) = _rootSemanticsView();
      var snapshot = const SemanticsSnapshotBuilder().build(
        root,
        devicePixelRatio: devicePixelRatio,
      );

      if (textScales.any((scale) => scale != 1.0)) {
        final observations = await const TextScaleCollector().collect(
          this,
          textScales,
        );
        snapshot = SemanticsSnapshot(
          root: snapshot.root,
          contrastSamples: snapshot.contrastSamples,
          textScaleObservations: observations,
        );
      }

      return (engine ?? RuleEngine.standard()).run(
        snapshot,
        meta: AuditMeta(
          screenName: screenName,
          standard: _defaultStandard,
          toolVersion: attestVersion,
          timestamp: DateTime.now().toUtc(),
        ),
        config: config,
        gateSeverity: gateSeverity,
      );
    } finally {
      handle.dispose();
    }
  }

  (SemanticsNode, double) _rootSemanticsView() {
    for (final view in binding.renderViews) {
      final root = view.owner?.semanticsOwner?.rootSemanticsNode;
      if (root != null) return (root, view.flutterView.devicePixelRatio);
    }
    throw StateError(
      'No semantics tree is available. Pump a widget before calling '
      'auditAccessibility().',
    );
  }
}
