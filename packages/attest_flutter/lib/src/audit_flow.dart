import 'package:attest/attest.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

import 'audit_extension.dart';

/// One labelled step in an accessibility flow: an interaction to perform, after
/// which the screen is audited again.
///
/// The [action] drives the same [WidgetTester] — tap a finder, scroll, open a
/// route — and typically settles the frame (`await tester.pumpAndSettle()`).
@immutable
class AuditStep {
  /// Creates an [AuditStep] with a human-readable [label] and its [action].
  const AuditStep(this.label, this.action);

  /// A short description of the interaction, used to label the step's report.
  final String label;

  /// The interaction to perform before the next audit.
  final Future<void> Function(WidgetTester tester) action;
}

/// Accessibility auditing **across interactions** for [WidgetTester].
///
/// **Experimental.** Static, single-screen auditing only sees one moment in
/// time. Many real barriers appear in motion: an unlabeled control revealed in
/// a dialog, semantics that break after a state change, a focus trap that only
/// exists post-navigation. This drives a scripted flow and re-audits after each
/// step, so those are caught too. The API is young and expected to grow
/// (specialised cross-step checks, flow diffing), so it is exempt from the 1.0
/// stability promise.
extension AccessibilityFlowAudit on WidgetTester {
  /// Audits the current screen, then performs each step in [steps] and audits
  /// again, returning one report per audit (initial first).
  ///
  /// Each report's [AuditMeta.screenName] is labelled with the step, so the
  /// aggregate reads as a trail through the flow:
  ///
  /// ```dart
  /// final reports = await tester.auditFlow(
  ///   screenName: 'Checkout',
  ///   steps: [
  ///     AuditStep('open coupon dialog', (t) async {
  ///       await t.tap(find.text('Add coupon'));
  ///       await t.pumpAndSettle();
  ///     }),
  ///   ],
  /// );
  /// expect(reports, everyElement(passesAccessibilityGate()));
  /// ```
  ///
  /// The audit parameters mirror [AccessibilityAudit.auditAccessibility] and
  /// apply to every step.
  Future<List<AuditReport>> auditFlow({
    required List<AuditStep> steps,
    String screenName = 'flow',
    RuleEngine? engine,
    RuleConfig config = const RuleConfig(),
    Severity gateSeverity = Severity.error,
    List<double> textScales = const [1.0, 1.3, 2.0],
    bool contrast = true,
    bool transcript = true,
  }) async {
    Future<AuditReport> auditAs(String label) => auditAccessibility(
      screenName: '$screenName · $label',
      engine: engine,
      config: config,
      gateSeverity: gateSeverity,
      textScales: textScales,
      contrast: contrast,
      transcript: transcript,
    );

    final reports = <AuditReport>[await auditAs('initial')];
    for (final step in steps) {
      await step.action(this);
      reports.add(await auditAs(step.label));
    }
    return reports;
  }
}
