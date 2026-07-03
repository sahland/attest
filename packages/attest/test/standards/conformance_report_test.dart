import 'package:attest/attest.dart';
import 'package:test/test.dart';

void main() {
  Finding finding(String wcag) => Finding(
        ruleId: 'attest/rule',
        criterion: Criterion(
          wcag: wcag,
          wcagLevel: 'A',
          en301549: '11.$wcag',
          title: 'x',
        ),
        severity: Severity.error,
        confidence: Confidence.deterministic,
        message: 'm',
        suggestion: 's',
        fingerprint: 'fp-$wcag',
      );

  ConformanceReport build(List<Finding> findings) => ConformanceReport.build(
        standard: Standard.en301549_v3_2_1,
        findings: findings,
        toolVersion: '9.9.9',
        generatedAt: DateTime.utc(2026),
      );

  test('has an entry for every criterion in the pack', () {
    final report = build(const []);
    final matrix = CoverageMatrix.forStandard(Standard.en301549_v3_2_1);
    expect(report.entries, hasLength(matrix.total));
  });

  test('maps a finding onto the clause it cites', () {
    final report = build([finding('1.4.3')]);
    final entry = report.entries.firstWhere((e) => e.criterion.wcag == '1.4.3');
    expect(entry.findings, hasLength(1));
    expect(report.findingCount, 1);
  });

  test('manual clauses appear even with no findings and need review', () {
    final report = build(const []);
    final entry = report.entries.firstWhere((e) => e.criterion.wcag == '1.4.1');
    expect(entry.status, CoverageStatus.manual);
    expect(entry.findings, isEmpty);
    expect(entry.needsManualReview, isTrue);
  });

  test('an automated clause does not need manual review', () {
    final report = build(const []);
    final entry = report.entries.firstWhere((e) => e.criterion.wcag == '1.4.3');
    expect(entry.needsManualReview, isFalse);
  });

  test('the JSON carries schema, standard, summary and criteria', () {
    final json = build([finding('4.1.2')]).toJson();
    expect(json['schemaVersion'], '1');
    expect(json['standard'], 'en301549_v3_2_1');
    expect((json['tool'] as Map)['name'], 'attest');
    final summary = json['summary'] as Map<String, dynamic>;
    expect(summary['findings'], 1);
    expect(
      summary['automated'] as int,
      greaterThan(0),
    );
    expect((json['criteria'] as List).length, (build(const [])).entries.length);
  });

  test('WCAG 2.2-only clauses only appear under the wcag22 pack', () {
    final en = ConformanceReport.build(
      standard: Standard.en301549_v3_2_1,
      findings: const [],
      toolVersion: 't',
    );
    final wcag22 = ConformanceReport.build(
      standard: Standard.wcag22,
      findings: const [],
      toolVersion: 't',
    );
    bool has(ConformanceReport r, String wcag) =>
        r.entries.any((e) => e.criterion.wcag == wcag);
    expect(has(en, '2.5.8'), isFalse);
    expect(has(wcag22, '2.5.8'), isTrue);
  });
}
