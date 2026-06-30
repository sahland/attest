import 'package:attest/attest.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'snapshot_builder.dart';

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
  /// set, [config] to tune the rules, and [gateSeverity] to change which
  /// findings fail the gate.
  Future<AuditReport> auditAccessibility({
    String screenName = 'screen',
    RuleEngine? engine,
    RuleConfig config = const RuleConfig(),
    Severity gateSeverity = Severity.error,
  }) async {
    final handle = ensureSemantics();
    await pump();
    try {
      final (root, devicePixelRatio) = _rootSemanticsView();
      final snapshot = const SemanticsSnapshotBuilder().build(
        root,
        devicePixelRatio: devicePixelRatio,
      );
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
