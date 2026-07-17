import 'package:attest_flutter/attest_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Performance and large-box correctness of the raster contrast pipeline.
///
/// The background scan reads packed pixels directly (no per-pixel allocation)
/// and subsamples large boxes with a stride, so a busy screen stays cheap. The
/// budget below is a loose tripwire for a super-linear regression, not a
/// benchmark; the second test pins that the stride does not change the measured
/// background on a box far larger than the sampling cap.
void main() {
  /// A generous per-screen ceiling. Locally the dense screen collects in tens
  /// of milliseconds; this only fails if collection becomes super-linear.
  const budget = Duration(seconds: 2);

  testWidgets('a dense screen is collected within the budget', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const nodes = 240;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
            width: 1200,
            height: 4000,
            child: Wrap(
              children: [
                for (var i = 0; i < nodes; i++)
                  Container(
                    width: 300,
                    height: 60,
                    color: i.isEven ? Colors.white : const Color(0xFFEEEEEE),
                    alignment: Alignment.center,
                    child: Text(
                      'Row number $i of the dense benchmark screen',
                      style: const TextStyle(
                        color: Color(0xFF404040),
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    const collector = RasterCollector();
    await collector.collect(tester); // warm up

    var best = const Duration(days: 1);
    for (var run = 0; run < 3; run++) {
      final sw = Stopwatch()..start();
      final samples = await collector.collect(tester);
      sw.stop();
      if (sw.elapsed < best) best = sw.elapsed;
      expect(samples, hasLength(nodes));
    }

    printOnFailure('best of three: ${best.inMilliseconds} ms for $nodes nodes');
    expect(
      best,
      lessThan(budget),
      reason:
          'collect took ${best.inMilliseconds} ms; '
          'budget is ${budget.inMilliseconds} ms',
    );
  });

  testWidgets('subsampling a large box preserves the background mode', (
    tester,
  ) async {
    // #767676 on white is the canonical 4.54:1 reference pair. Rendered at a
    // large size the text box is far bigger than the sampling cap, so the scan
    // strides — this proves the stride still finds the solid white background.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Text(
              'Large heading sample',
              style: TextStyle(color: Color(0xFF767676), fontSize: 96),
            ),
          ),
        ),
      ),
    );

    final samples = await const RasterCollector().collect(tester);
    final sample = samples.firstWhere((s) => s.label == 'Large heading sample');

    // A box this large must have triggered striding, and the ratio must still
    // match the independently known reference within the collector's tolerance.
    expect(sample.bounds.width * sample.bounds.height, greaterThan(1024));
    expect(sample.contrastRatio, closeTo(4.54, 0.1));
  });
}
