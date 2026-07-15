import 'package:attest/attest.dart';
import 'package:test/test.dart';

void main() {
  const criterion = Criterion(
    wcag: '4.1.2',
    wcagLevel: 'A',
    en301549: '11.4.1.2',
    title: 'Name, Role, Value',
    understanding:
        'https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html',
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
        codeExample: '// After\nIconButton(tooltip: "Share", ...)',
        fingerprint: 'abc123',
        location: SourceLocation(file: 'lib/pay.dart', line: 42, column: 5),
      ),
    ],
    meta: AuditMeta(
      screenName: 'CheckoutScreen',
      standard: 'en301549_v3_2_1',
      toolVersion: '0.6.0',
      timestamp: DateTime.utc(2026),
    ),
  );

  test('emits a well-formed SARIF 2.1.0 document', () {
    final sarif = const SarifWriter(toolVersion: '0.6.0').write([report]);

    expect(sarif['version'], '2.1.0');
    expect(sarif[r'$schema'], isA<String>());

    final run = (sarif['runs'] as List).single as Map<String, dynamic>;
    final driver = (run['tool'] as Map)['driver'] as Map<String, dynamic>;
    expect(driver['name'], 'attest');
    expect(driver['version'], '0.6.0');
    expect(driver['rules'], hasLength(1));

    final rule = (driver['rules'] as List).single as Map<String, dynamic>;
    expect(
      rule['helpUri'],
      'https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html',
    );

    final result = (run['results'] as List).single as Map<String, dynamic>;
    expect(result['ruleId'], 'attest/interactive-name');
    expect(
      (result['properties'] as Map)['codeExample'],
      contains('IconButton'),
    );
    expect(result['level'], 'error');
    expect((result['message'] as Map)['text'], isNotEmpty);
    expect(
      (result['partialFingerprints'] as Map)['attest/v1'],
      'abc123',
    );

    final physical = ((result['locations'] as List).single
        as Map<String, dynamic>)['physicalLocation'] as Map<String, dynamic>;
    expect(
      (physical['artifactLocation'] as Map)['uri'],
      'lib/pay.dart',
    );
    expect((physical['region'] as Map)['startLine'], 42);
  });

  test('maps severities to SARIF levels', () {
    Finding at(Severity severity) => Finding(
          ruleId: 'attest/x',
          criterion: criterion,
          severity: severity,
          confidence: Confidence.deterministic,
          message: 'm',
          suggestion: 's',
          fingerprint: 'f-${severity.name}',
        );
    final sarif = const SarifWriter().write([
      AuditReport(
        findings: [at(Severity.error), at(Severity.warning), at(Severity.info)],
        meta: report.meta,
      ),
    ]);
    final levels = [
      for (final r in sarif['runs'][0]['results'] as List) (r as Map)['level'],
    ];
    expect(levels, ['error', 'warning', 'note']);
  });
}
