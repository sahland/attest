import 'package:attest/attest.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

/// Re-pumps the current screen at enlarged text scales and records whether the
/// layout overflows.
///
/// It drives the system text size through
/// `TestPlatformDispatcher.textScaleFactorTestValue`, so it re-lays-out the tree
/// already under test without needing a reference to the widget. A layout
/// overflow surfaces as a captured framework exception, which is drained with
/// `takeException` so it enriches the snapshot instead of failing the test.
///
/// **Experimental:** most tests only need `tester.auditAccessibility()`, which
/// drives this internally. The collector's own signature may still evolve, so
/// it is exempt from the 1.0 stability promise.
@experimental
class TextScaleCollector {
  /// Creates a [TextScaleCollector].
  const TextScaleCollector();

  /// Re-pumps at each scale in [textScales] (skipping 1.0) and returns one
  /// observation per scale, restoring the original text size afterwards.
  Future<List<TextScaleObservation>> collect(
    WidgetTester tester,
    List<double> textScales,
  ) async {
    final observations = <TextScaleObservation>[];

    for (final scale in textScales) {
      if (scale == 1.0) continue;

      tester.platformDispatcher.textScaleFactorTestValue = scale;
      await tester.pump();

      final exception = tester.takeException();
      final message = exception?.toString() ?? '';
      final overflowed = message.toLowerCase().contains('overflow');

      observations.add(
        TextScaleObservation(
          textScale: scale,
          overflowed: overflowed,
          details: overflowed ? _firstLine(message) : '',
        ),
      );
    }

    tester.platformDispatcher.clearTextScaleFactorTestValue();
    await tester.pump();
    return observations;
  }

  String _firstLine(String message) {
    final newline = message.indexOf('\n');
    return newline == -1
        ? message.trim()
        : message.substring(0, newline).trim();
  }
}
