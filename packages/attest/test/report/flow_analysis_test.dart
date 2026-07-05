import 'package:attest/attest.dart';
import 'package:test/test.dart';

void main() {
  AuditReport reportWith(List<String> fingerprints) => AuditReport(
        findings: [
          for (final fp in fingerprints)
            Finding(
              ruleId: 'attest/x',
              criterion: const Criterion(
                wcag: '4.1.2',
                wcagLevel: 'A',
                en301549: '11.4.1.2',
                title: 'x',
              ),
              severity: Severity.error,
              confidence: Confidence.deterministic,
              message: 'm',
              suggestion: 's',
              fingerprint: fp,
            ),
        ],
        meta: AuditMeta(
          screenName: 'step',
          standard: 'en301549_v3_2_1',
          toolVersion: 'test',
          timestamp: DateTime.utc(2026),
        ),
      );

  test('the first report introduces all of its own findings', () {
    final flow = FlowAnalysis.of([
      reportWith(['a', 'b']),
    ]);
    expect(flow.steps.single.introduced.map((f) => f.fingerprint), ['a', 'b']);
    expect(flow.steps.single.resolved, isEmpty);
  });

  test('a later step introduces only its new findings', () {
    final flow = FlowAnalysis.of([
      reportWith(['a']),
      reportWith(['a', 'b']),
    ]);
    expect(flow.steps[1].introduced.map((f) => f.fingerprint), ['b']);
    expect(flow.steps[1].resolved, isEmpty);
  });

  test('a step records findings it resolves', () {
    final flow = FlowAnalysis.of([
      reportWith(['a', 'b']),
      reportWith(['a']),
    ]);
    expect(flow.steps[1].introduced, isEmpty);
    expect(flow.steps[1].resolved, ['b']);
  });

  test('introducedByInteractions excludes the initial screen', () {
    final flow = FlowAnalysis.of([
      reportWith(['a']), // initial
      reportWith(['a', 'b']), // step introduces b
      reportWith(['a', 'c']), // step resolves b, introduces c
    ]);
    expect(
      flow.introducedByInteractions.map((f) => f.fingerprint),
      ['b', 'c'],
    );
    expect(flow.anyInteractionRegressed, isTrue);
  });

  test('a flow that adds nothing after the first step is clean', () {
    final flow = FlowAnalysis.of([
      reportWith(['a']),
      reportWith(['a']),
    ]);
    expect(flow.anyInteractionRegressed, isFalse);
  });

  test('the JSON lists introduced and resolved per step', () {
    final json = FlowAnalysis.of([
      reportWith(['a']),
      reportWith(['b']),
    ]).toJson();
    final steps = json['steps'] as List;
    expect(steps, hasLength(2));
    expect((steps[1] as Map<String, dynamic>)['resolved'], ['a']);
  });
}
