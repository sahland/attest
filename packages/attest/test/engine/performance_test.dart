import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';

/// The per-screen audit-time budget (Phase 1, P1.6).
///
/// A per-PR CI run audits every screen in a test suite, so a single audit must
/// stay cheap. The budget below is deliberately far above today's measured
/// time (single-digit milliseconds for this screen): it is not a benchmark but
/// a tripwire for an accidental super-linear blowup — a rule that exceeds it
/// gets optimized, not merged.
const Duration perScreenBudget = Duration(milliseconds: 250);

/// Nodes in the synthetic screen, sized well beyond a realistic screen's
/// semantics tree (a heavy production screen is typically a few hundred).
const int _nodeCount = 2000;

void main() {
  final meta = AuditMeta(
    screenName: 'PerformanceScreen',
    standard: 'en301549_v3_2_1',
    toolVersion: 'test',
    timestamp: DateTime.utc(2026),
  );

  /// A large, varied screen: [_nodeCount] nodes in groups of ten, mixing named
  /// and unnamed controls, images, fields, headings and duplicate labels, plus
  /// contrast samples and text-scale observations.
  SemanticsSnapshot bigScreen() {
    final groups = <SemanticsNodeData>[];
    for (var g = 0; g < _nodeCount ~/ 10; g++) {
      final top = g * 60.0;
      groups.add(
        node(
          bounds: rect(0, top, 400, 60),
          children: [
            node(
              label: 'Item $g',
              bounds: rect(0, top, 100, 48),
              textStyle: const TextStyleData(fontSize: 14),
            ),
            node(
              flags: {isButton},
              actions: {tap},
              bounds: rect(100, top, 40, 40),
            ),
            node(
              label: 'Open',
              flags: {isButton},
              actions: {tap},
              bounds: rect(140, top, 80, 48),
            ),
            node(flags: {isImage}, bounds: rect(220, top, 48, 48)),
            node(flags: {isTextField}, bounds: rect(270, top, 80, 48)),
            node(
              label: 'button',
              flags: {isButton},
              actions: {tap},
              bounds: rect(350, top, 48, 48),
            ),
            node(
              label: 'Day',
              actions: {tap},
              bounds: rect(0, top + 48, 60, 12),
            ),
            node(
              label: 'Week',
              actions: {tap},
              bounds: rect(60, top + 48, 60, 12),
            ),
            node(
              label: 'Heading $g',
              textStyle: const TextStyleData(fontSize: 26),
              bounds: rect(120, top + 48, 120, 12),
            ),
            node(label: 'caption', bounds: rect(240, top + 48, 60, 12)),
          ],
        ),
      );
    }

    return snap(
      node(bounds: rect(0, 0, 400, _nodeCount * 6.0), children: groups),
      contrastSamples: [
        for (var i = 0; i < 100; i++)
          ContrastSample(
            label: 'sample $i',
            foregroundLuminance: 0.0,
            backgroundLuminance: i.isEven ? 0.05 : 0.9,
            bounds: rect(0, i * 20.0, 100, 16),
            fontSize: 14,
          ),
      ],
      textScaleObservations: const [
        TextScaleObservation(textScale: 1.3, overflowed: false),
        TextScaleObservation(textScale: 2.0, overflowed: true),
      ],
    );
  }

  test('a $_nodeCount-node screen audits within the budget', () {
    final engine = RuleEngine.standard();
    final snapshot = bigScreen();

    // The screen must be genuinely busy, or the measurement is meaningless.
    expect(snapshot.allNodes.length, greaterThanOrEqualTo(_nodeCount));

    // Warm up the JIT, then take the best of five runs: the budget bounds the
    // engine's cost, not the CI machine's scheduling noise.
    for (var i = 0; i < 2; i++) {
      engine.run(snapshot, meta: meta);
    }

    var best = const Duration(days: 1);
    final stopwatch = Stopwatch();
    for (var i = 0; i < 5; i++) {
      stopwatch
        ..reset()
        ..start();
      final report = engine.run(snapshot, meta: meta);
      stopwatch.stop();
      if (stopwatch.elapsed < best) best = stopwatch.elapsed;
      expect(report.findings, isNotEmpty);
    }

    printOnFailure('best of five: ${best.inMicroseconds} µs');
    expect(
      best,
      lessThan(perScreenBudget),
      reason: 'audit took ${best.inMilliseconds} ms; '
          'budget is ${perScreenBudget.inMilliseconds} ms',
    );
  });
}
