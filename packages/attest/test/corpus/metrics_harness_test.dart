import 'package:attest/attest.dart';
import 'package:attest/corpus.dart';
import 'package:test/test.dart';

/// Unit test for the metrics math over a tiny synthetic corpus whose expected
/// tallies are known by hand. A fake auditor returns scripted findings keyed by
/// each case's root identifier, so the harness — not any real rule — is what is
/// under test here.
void main() {
  Finding finding(String ruleId, String wcag, String identifier) => Finding(
        ruleId: ruleId,
        criterion: Criterion(
          wcag: wcag,
          wcagLevel: 'A',
          en301549: '',
          title: '',
        ),
        severity: Severity.error,
        confidence: Confidence.deterministic,
        message: '',
        suggestion: '',
        fingerprint: '$ruleId:$identifier',
        identifier: identifier,
      );

  CorpusCase isolated(
    String key,
    CorpusCategory category,
    String rule,
    List<ExpectedFinding> expected,
  ) =>
      CorpusCase(
        id: key,
        category: category,
        standard: Standard.en301549_v3_2_1,
        ruleUnderTest: rule,
        expected: expected,
        build: () => SemanticsSnapshot(
          root: SemanticsNodeData(id: 1, identifier: key),
        ),
      );

  ExpectedFinding expect_(String rule, String wcag, String id) =>
      ExpectedFinding(ruleId: rule, wcag: wcag, identifier: id);

  // Scripted auditor output, keyed by each case's root identifier.
  final scripted = <String, List<Finding>>{
    // Positive, caught, plus an out-of-scope finding that isolation must drop.
    'a': [finding('r/x', '1.1.1', 'off.a'), finding('r/other', '2.2.2', 'z')],
    // Positive, missed entirely -> false negative.
    'b': const [],
    // Clean, but the rule fires -> false positive on a clean case.
    'c': [finding('r/x', '1.1.1', 'spurious')],
    // Adversarial, silent -> nothing.
    'd': const [],
    // Positive, caught, plus one extra false positive alongside the true one.
    'e': [finding('r/x', '1.1.1', 'off.e'), finding('r/x', '1.1.1', 'extra')],
  };

  final cases = [
    isolated(
      'a',
      CorpusCategory.positive,
      'r/x',
      [expect_('r/x', '1.1.1', 'off.a')],
    ),
    isolated(
      'b',
      CorpusCategory.positive,
      'r/x',
      [expect_('r/x', '1.1.1', 'off.b')],
    ),
    isolated('c', CorpusCategory.clean, 'r/x', const []),
    isolated('d', CorpusCategory.adversarial, 'r/x', const []),
    isolated(
      'e',
      CorpusCategory.positive,
      'r/x',
      [expect_('r/x', '1.1.1', 'off.e')],
    ),
  ];

  MetricsHarness harness({Map<String, Confidence>? confidence}) =>
      MetricsHarness(
        auditor: (snapshot, standard) =>
            scripted[snapshot.root.identifier] ?? const [],
        confidenceByRule: confidence ?? const {'r/x': Confidence.deterministic},
      );

  test('tallies TP, FP, FN by hand-verified counts', () async {
    final metrics = await harness().run(cases);
    final x = metrics.byRule['r/x']!;

    // TP: a + e = 2; FN: b = 1; FP: c(spurious) + e(extra) = 2.
    expect(x.truePositives, 2);
    expect(x.falseNegatives, 1);
    expect(x.falsePositives, 2);
    expect(x.falsePositivesOnClean, 1); // only c is a clean case
    expect(x.cleanCases, 1);
  });

  test('derives precision, recall and fpRateOnClean', () async {
    final x = (await harness().run(cases)).byRule['r/x']!;
    expect(x.precision, closeTo(0.5, 1e-9)); // 2 / (2 + 2)
    expect(x.recall, closeTo(2 / 3, 1e-9)); // 2 / (2 + 1)
    expect(x.fpRateOnClean, closeTo(1.0, 1e-9)); // 1 FP / 1 clean case
  });

  test('isolation drops findings from other rules', () async {
    final metrics = await harness().run(cases);
    expect(metrics.byRule.containsKey('r/other'), isFalse);
  });

  test('gate flags a deterministic rule that false-positives', () async {
    final metrics = await harness().run(cases);
    final violations = metrics.gateViolations(
      confidenceByRule: const {'r/x': Confidence.deterministic},
    );
    expect(
      violations.map((v) => v.kind),
      containsAll(const [
        GateViolationKind.deterministicPrecision,
        GateViolationKind.falsePositiveOnClean,
      ]),
    );
  });

  test('a heuristic rule with no threshold is not gated on precision',
      () async {
    final metrics =
        await harness(confidence: {'r/x': Confidence.heuristic}).run(cases);
    final violations = metrics.gateViolations(
      confidenceByRule: const {'r/x': Confidence.heuristic},
    );
    // fpOnClean still fires; the deterministic-precision breach must not.
    expect(
      violations.map((v) => v.kind),
      isNot(contains(GateViolationKind.deterministicPrecision)),
    );
    expect(
      violations.map((v) => v.kind),
      contains(GateViolationKind.falsePositiveOnClean),
    );
  });

  test('a heuristic rule below its declared threshold is gated', () async {
    final metrics =
        await harness(confidence: {'r/x': Confidence.heuristic}).run(cases);
    final violations = metrics.gateViolations(
      confidenceByRule: const {'r/x': Confidence.heuristic},
      heuristicPrecisionThresholds: const {'r/x': 0.9},
    );
    expect(
      violations.map((v) => v.kind),
      contains(GateViolationKind.heuristicPrecision),
    );
  });

  test('recall regression against a baseline is gated', () async {
    final current = await harness().run(cases);
    // Baseline recorded a higher recall for r/x than the current run.
    final baseline = CorpusMetrics.fromJson({
      'rules': [
        {'ruleId': 'r/x', 'truePositives': 3, 'falseNegatives': 0},
      ],
    });
    final violations = current.gateViolations(
      confidenceByRule: const {'r/x': Confidence.deterministic},
      baseline: baseline,
    );
    expect(
      violations.map((v) => v.kind),
      contains(GateViolationKind.recallRegression),
    );
  });

  test('metrics survive a JSON round-trip', () async {
    final metrics = await harness().run(cases);
    final restored = CorpusMetrics.fromJson(metrics.toJson());
    final x = restored.byRule['r/x']!;
    expect(x.truePositives, 2);
    expect(x.falsePositives, 2);
    expect(x.falseNegatives, 1);
    expect(x.precision, closeTo(0.5, 1e-9));
  });
}
