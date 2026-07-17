import 'dart:convert';
import 'dart:io';

import 'package:attest/attest.dart';
import 'package:attest_cli/attest_cli.dart';
import 'package:test/test.dart';

void main() {
  late Directory temp;
  late String reportDir;
  late String baselinePath;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('attest_cli_test');
    reportDir = '${temp.path}/reports';
    Directory(reportDir).createSync(recursive: true);
    baselinePath = '${temp.path}/baseline.json';

    final report = AuditReport(
      findings: const [
        Finding(
          ruleId: 'attest/interactive-name',
          criterion: Criterion(
            wcag: '4.1.2',
            wcagLevel: 'A',
            en301549: '11.4.1.2',
            title: 'Name, Role, Value',
          ),
          severity: Severity.error,
          confidence: Confidence.deterministic,
          message: 'Button has no accessible name.',
          suggestion: 'Add a Semantics label.',
          fingerprint: 'fp-1',
        ),
      ],
      meta: AuditMeta(
        screenName: 'CheckoutScreen',
        standard: 'en301549_v3_2_1',
        toolVersion: '0.6.0',
        timestamp: DateTime.utc(2026),
      ),
      transcript: const ['Total, heading', 'Pay, button'],
    );
    File('$reportDir/checkout.json').writeAsStringSync(
      jsonEncode(report.toJson()),
    );
  });

  tearDown(() => temp.deleteSync(recursive: true));

  Future<int?> run(List<String> args) => buildAttestRunner().run(args);

  test('ci fails on a new finding, then passes after baseline --update',
      () async {
    expect(
      await run(['ci', '--report-dir', reportDir, '--baseline', baselinePath]),
      1,
    );

    expect(
      await run([
        'baseline',
        '--update',
        '--report-dir',
        reportDir,
        '--baseline',
        baselinePath,
      ]),
      0,
    );
    expect(File(baselinePath).existsSync(), isTrue);

    expect(
      await run(['ci', '--report-dir', reportDir, '--baseline', baselinePath]),
      0,
    );
  });

  test('baseline --update records the finding fingerprint', () async {
    await run([
      'baseline',
      '--update',
      '--report-dir',
      reportDir,
      '--baseline',
      baselinePath,
    ]);
    final baseline = Baseline.fromJson(
      jsonDecode(File(baselinePath).readAsStringSync()) as Map<String, dynamic>,
    );
    expect(baseline.fingerprints, contains('fp-1'));
  });

  test('ci --format sarif writes a SARIF document', () async {
    final outputPath = '${temp.path}/out.sarif';
    await run([
      'ci',
      '--report-dir',
      reportDir,
      '--baseline',
      baselinePath,
      '--format',
      'sarif',
      '--output',
      outputPath,
    ]);
    final sarif =
        jsonDecode(File(outputPath).readAsStringSync()) as Map<String, dynamic>;
    expect(sarif['version'], '2.1.0');
    expect((sarif['runs'] as List).single, isA<Map<String, dynamic>>());
  });

  test('transcript runs over the reports', () async {
    expect(await run(['transcript', '--report-dir', reportDir]), 0);
  });

  test('coverage prints the matrix for each pack and format', () async {
    expect(await run(['coverage']), 0);
    expect(
      await run(['coverage', '--standard', 'wcag22', '--format', 'json']),
      0,
    );
  });

  test('ci --format conformance writes a machine-readable document', () async {
    final outputPath = '${temp.path}/conformance.json';
    await run([
      'ci',
      '--report-dir',
      reportDir,
      '--baseline',
      baselinePath,
      '--format',
      'conformance',
      '--output',
      outputPath,
    ]);
    final doc =
        jsonDecode(File(outputPath).readAsStringSync()) as Map<String, dynamic>;
    expect(doc['schemaVersion'], '1');
    expect(doc['standard'], 'en301549_v3_2_1');
    expect(doc['summary'], isA<Map<String, dynamic>>());
    final criteria = doc['criteria'] as List;
    expect(criteria, isNotEmpty);
    // A manual criterion is present with guidance and no rules.
    final manual = criteria.cast<Map<String, dynamic>>().firstWhere(
          (c) => (c['criterion'] as Map)['wcag'] == '1.4.1',
        );
    expect(manual['status'], 'manual');
    expect(manual['needsManualReview'], isTrue);
    expect(manual['guidance'], isA<String>());
  });

  test('ci --format html embeds the manual-review checklist', () async {
    final outputPath = '${temp.path}/out.html';
    await run([
      'ci',
      '--report-dir',
      reportDir,
      '--baseline',
      baselinePath,
      '--format',
      'html',
      '--output',
      outputPath,
    ]);
    final html = File(outputPath).readAsStringSync();
    expect(html, contains('Manual review checklist'));
    // A criterion that is manual-only must appear as a checklist item.
    expect(html, contains('Use of Color'));
    expect(html, contains('type="checkbox"'));
  });

  test('ci --history records a trend log and reports the change', () async {
    final historyPath = '${temp.path}/history.json';
    final outPath = '${temp.path}/out.txt';

    List<String> ciArgs() => [
          'ci',
          '--report-dir',
          reportDir,
          '--baseline',
          baselinePath,
          '--history',
          historyPath,
          '--output',
          outPath,
        ];

    TrendLog readLog() => TrendLog.fromJson(
          jsonDecode(File(historyPath).readAsStringSync())
              as Map<String, dynamic>,
        );

    // First run creates the log and reports the first recorded run.
    await run(ciArgs());
    expect(readLog().runs, hasLength(1));
    expect(File(outPath).readAsStringSync(), contains('first recorded run'));

    // Second run appends and, with the same reports, reports no change.
    await run(ciArgs());
    final log = readLog();
    expect(log.runs, hasLength(2));
    expect(log.runs.last.total, 1);
    expect(File(outPath).readAsStringSync(), contains('no change since last'));
  });
}
