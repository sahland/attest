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
}
