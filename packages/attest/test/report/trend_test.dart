import 'package:attest/attest.dart';
import 'package:test/test.dart';

void main() {
  const criterion = Criterion(
    wcag: '4.1.2',
    wcagLevel: 'A',
    en301549: '11.4.1.2',
    title: 'Name, Role, Value',
  );

  Finding finding(Severity severity, String fingerprint) => Finding(
        ruleId: 'attest/interactive-name',
        criterion: criterion,
        severity: severity,
        confidence: Confidence.deterministic,
        message: 'm',
        suggestion: 's',
        fingerprint: fingerprint,
      );

  final t0 = DateTime.utc(2026, 7, 2);
  final t1 = DateTime.utc(2026, 7, 8);

  group('RunSummary', () {
    test('counts total and per-severity findings', () {
      final summary = RunSummary.of(
        [
          finding(Severity.error, 'a'),
          finding(Severity.error, 'b'),
          finding(Severity.warning, 'c'),
        ],
        timestamp: t0,
      );
      expect(summary.total, 3);
      expect(summary.count(Severity.error), 2);
      expect(summary.count(Severity.warning), 1);
      expect(summary.count(Severity.info), 0);
    });

    test('round-trips through JSON', () {
      final summary = RunSummary.of(
        [finding(Severity.error, 'a'), finding(Severity.warning, 'b')],
        timestamp: t0,
        newCount: 1,
        resolvedCount: 2,
      );
      final restored = RunSummary.fromJson(summary.toJson());
      expect(restored.total, summary.total);
      expect(restored.timestamp, summary.timestamp);
      expect(restored.newCount, 1);
      expect(restored.resolvedCount, 2);
      expect(restored.count(Severity.error), 1);
      expect(restored.count(Severity.warning), 1);
    });

    test('summarizeRun derives counts from a gate result', () {
      final gate = BaselineGate(
        Baseline.fromFindings([finding(Severity.error, 'a')]),
      ).evaluate(
        [finding(Severity.error, 'a'), finding(Severity.warning, 'b')],
      );
      final summary = summarizeRun(gate, timestamp: t0);
      expect(summary.total, 2);
      expect(summary.newCount, 1); // the warning 'b' is new
      expect(summary.resolvedCount, 0);
    });
  });

  group('TrendLog', () {
    test('append keeps runs oldest-first and caps the history', () {
      var log = TrendLog.empty;
      for (var i = 0; i < 5; i++) {
        log = log.append(
          RunSummary.of(const [], timestamp: t0.add(Duration(days: i))),
          keepLast: 3,
        );
      }
      expect(log.runs, hasLength(3));
      // Oldest kept is day 2, newest is day 4.
      expect(log.runs.first.timestamp, t0.add(const Duration(days: 2)));
      expect(log.runs.last.timestamp, t0.add(const Duration(days: 4)));
    });

    test('latestDelta compares the last two runs', () {
      final log = TrendLog.empty
          .append(
            RunSummary.of(
              [finding(Severity.error, 'a'), finding(Severity.error, 'b')],
              timestamp: t0,
            ),
          )
          .append(
            RunSummary.of([finding(Severity.error, 'a')], timestamp: t1),
          );
      final delta = log.latestDelta!;
      expect(delta.hasPrevious, isTrue);
      expect(delta.totalDelta, -1);
      expect(delta.improved, isTrue);
      expect(delta.regressed, isFalse);
      expect(delta.severityDelta(Severity.error), -1);
    });

    test('latestDelta has no previous for the first run', () {
      final log = TrendLog.empty.append(
        RunSummary.of([finding(Severity.error, 'a')], timestamp: t0),
      );
      final delta = log.latestDelta!;
      expect(delta.hasPrevious, isFalse);
      expect(delta.totalDelta, 1); // equals current total
      expect(delta.improved, isFalse);
    });

    test('empty log has no latest delta', () {
      expect(TrendLog.empty.latestDelta, isNull);
    });

    test('round-trips through JSON', () {
      final log = TrendLog.empty
          .append(RunSummary.of([finding(Severity.error, 'a')], timestamp: t0))
          .append(RunSummary.of(const [], timestamp: t1));
      final restored = TrendLog.fromJson(log.toJson());
      expect(restored.runs, hasLength(2));
      expect(restored.runs.first.total, 1);
      expect(restored.runs.last.total, 0);
      expect(restored.latestDelta!.totalDelta, -1);
    });
  });
}
