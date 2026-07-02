import 'dart:convert';
import 'dart:io';

import 'package:attest/corpus.dart';
import 'package:test/test.dart';

import 'all_cases.dart';

/// The corpus metrics gate (P1.2): the real engine is run over every corpus
/// case, per-rule precision/recall/FP are computed, and the build fails on any
/// gate breach — a deterministic rule that false-positives, a false positive on
/// a clean case, a heuristic below its declared threshold, or a recall
/// regression against the committed baseline.
///
/// It writes `build/metrics/metrics.json` for inspection. To regenerate the
/// committed baseline after a deliberate corpus change, run with the environment
/// variable `UPDATE_METRICS_BASELINE=1`.
void main() {
  final baselineFile = File('test/corpus/metrics_baseline.json');
  const encoder = JsonEncoder.withIndent('  ');

  test('the corpus passes the metrics gate', () async {
    final harness = MetricsHarness();
    final metrics = await harness.run(corpusCases);

    File('build/metrics/metrics.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(encoder.convert(metrics.toJson()));
    printOnFailure(metrics.renderTable());

    if (Platform.environment['UPDATE_METRICS_BASELINE'] == '1') {
      baselineFile.writeAsStringSync(encoder.convert(metrics.toJson()));
    }

    final baseline = baselineFile.existsSync()
        ? CorpusMetrics.fromJson(
            jsonDecode(baselineFile.readAsStringSync()) as Map<String, dynamic>,
          )
        : null;

    // No expected finding should fail to anchor to its identifier.
    expect(metrics.warnings, isEmpty, reason: metrics.warnings.join('\n'));

    final violations = metrics.gateViolations(
      confidenceByRule: harness.confidenceByRule,
      baseline: baseline,
    );
    expect(
      violations,
      isEmpty,
      reason: violations.map((v) => v.toString()).join('\n'),
    );
  });
}
