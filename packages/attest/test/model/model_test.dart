import 'package:attest/attest.dart';
import 'package:test/test.dart';

void main() {
  const node = SemanticsNodeData(
    id: 1,
    identifier: 'checkout.pay-button',
    label: 'Pay',
    flags: {SemanticsFlagData.isButton, SemanticsFlagData.isEnabled},
    actions: {SemanticsActionData.tap},
    bounds: RectData(left: 8, top: 16, width: 48, height: 48),
    creator: SourceLocation(file: 'lib/pay.dart', line: 42, column: 5),
    textStyle: TextStyleData(fontSize: 18, fontWeight: 700),
    childrenInTraversalOrder: [
      SemanticsNodeData(id: 2, label: 'Pay now'),
    ],
  );

  const snapshot = SemanticsSnapshot(
    root: node,
    contrastSamples: [
      ContrastSample(
        label: 'Total',
        foregroundLuminance: 0.1,
        backgroundLuminance: 0.9,
        bounds: RectData.zero,
      ),
    ],
    textScaleObservations: [
      TextScaleObservation(textScale: 2, overflowed: true, nodeId: 2),
    ],
  );

  group('value equality', () {
    test('identical snapshots are equal and share a hashCode', () {
      const other = SemanticsSnapshot(
        root: SemanticsNodeData(
          id: 1,
          identifier: 'checkout.pay-button',
          label: 'Pay',
          flags: {
            SemanticsFlagData.isEnabled,
            SemanticsFlagData.isButton,
          },
          actions: {SemanticsActionData.tap},
          bounds: RectData(left: 8, top: 16, width: 48, height: 48),
          creator: SourceLocation(
            file: 'lib/pay.dart',
            line: 42,
            column: 5,
          ),
          textStyle: TextStyleData(fontSize: 18, fontWeight: 700),
          childrenInTraversalOrder: [
            SemanticsNodeData(id: 2, label: 'Pay now'),
          ],
        ),
        contrastSamples: [
          ContrastSample(
            label: 'Total',
            foregroundLuminance: 0.1,
            backgroundLuminance: 0.9,
            bounds: RectData.zero,
          ),
        ],
        textScaleObservations: [
          TextScaleObservation(textScale: 2, overflowed: true, nodeId: 2),
        ],
      );

      expect(other, equals(snapshot));
      expect(other.hashCode, equals(snapshot.hashCode));
    });

    test('a changed label breaks equality', () {
      const changed = SemanticsSnapshot(
        root: SemanticsNodeData(id: 1, label: 'Cancel'),
      );
      expect(changed, isNot(equals(snapshot)));
    });
  });

  group('JSON round-trip', () {
    test('snapshot survives a round-trip unchanged', () {
      final restored = SemanticsSnapshot.fromJson(snapshot.toJson());
      expect(restored, equals(snapshot));
    });

    test('report survives a round-trip unchanged', () {
      const criterion = Criterion(
        wcag: '4.1.2',
        wcagLevel: 'A',
        en301549: '11.5.2.5',
        title: 'Name, Role, Value',
      );
      final report = AuditReport(
        findings: const [
          Finding(
            ruleId: 'attest/interactive-name',
            criterion: criterion,
            severity: Severity.error,
            confidence: Confidence.deterministic,
            message: 'Button has no accessible name.',
            suggestion: 'Add a Semantics label.',
            fingerprint: 'abc123',
            identifier: 'checkout.pay-button',
            location: SourceLocation(file: 'lib/pay.dart', line: 42),
            bounds: RectData(left: 0, top: 0, width: 48, height: 48),
          ),
        ],
        meta: AuditMeta(
          screenName: 'CheckoutScreen',
          standard: 'en301549_v3_2_1',
          toolVersion: '0.1.0',
          timestamp: DateTime.utc(2026, 6, 30, 12),
        ),
      );

      final restored = AuditReport.fromJson(report.toJson());
      expect(restored, equals(report));
      expect(restored.passes, isFalse);
    });
  });

  group('derived behaviour', () {
    test('contrast ratio matches the WCAG formula', () {
      const sample = ContrastSample(
        label: 'x',
        foregroundLuminance: 0,
        backgroundLuminance: 1,
        bounds: RectData.zero,
      );
      // (1 + 0.05) / (0 + 0.05) = 21.
      expect(sample.contrastRatio, closeTo(21, 1e-9));
    });

    test('severity ordering gates correctly', () {
      expect(Severity.error.isAtLeast(Severity.warning), isTrue);
      expect(Severity.warning.isAtLeast(Severity.error), isFalse);
    });

    test('a clean report passes the gate', () {
      final report = AuditReport(
        findings: const [],
        meta: AuditMeta(
          screenName: 'Clean',
          standard: 'en301549_v3_2_1',
          toolVersion: '0.1.0',
          timestamp: DateTime.utc(2026),
        ),
      );
      expect(report.passes, isTrue);
    });
  });
}
