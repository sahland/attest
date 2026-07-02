import 'dart:math' as math;

import 'package:attest_flutter/attest_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reference validation of the hard measurement paths (Phase 1, P1.5).
///
/// The contrast pipeline is checked end to end against a table of known colour
/// pairs whose expected WCAG ratios are computed here, independently of the
/// collector, straight from the WCAG 2.x relative-luminance definition — and
/// that independent implementation is itself anchored to published reference
/// ratios. The overflow path is checked at both 1.0 and 2.0 text scale, on a
/// fixture proven not to overflow at 1.0.

// --- independent WCAG contrast math (kept deliberately separate from the
// --- collector's implementation) ---

double _channel(int value) {
  final s = value / 255;
  return s <= 0.03928
      ? s / 12.92
      : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
}

double _luminance(Color color) =>
    0.2126 * _channel((color.r * 255).round()) +
    0.7152 * _channel((color.g * 255).round()) +
    0.0722 * _channel((color.b * 255).round());

double _referenceRatio(Color foreground, Color background) {
  final fg = _luminance(foreground);
  final bg = _luminance(background);
  final hi = math.max(fg, bg);
  final lo = math.min(fg, bg);
  return (hi + 0.05) / (lo + 0.05);
}

// --- fixtures ---

const String _sampleText = 'Reference sample';

Widget _pairScreen(Color foreground, Color background) => MaterialApp(
  home: Scaffold(
    backgroundColor: background,
    body: Center(
      child: Text(
        _sampleText,
        style: TextStyle(color: foreground, fontSize: 16),
      ),
    ),
  ),
);

Widget _overflowScreen({required bool flexible}) {
  // Ten characters at the default 14px test font is ~140px: it fits the
  // 200px box beside a 24px icon at scale 1.0 and overflows at 2.0.
  const label = Text('AAAAAAAAAA', maxLines: 1);
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 200,
          child: Row(
            children: [
              if (flexible) const Flexible(child: label) else label,
              const Icon(Icons.info),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('independent maths reproduce published reference ratios', () {
    test('anchors match WCAG-published values', () {
      // Values as published by standard contrast checkers (WebAIM et al.).
      expect(_referenceRatio(Colors.black, Colors.white), closeTo(21.00, 0.01));
      expect(
        _referenceRatio(const Color(0xFF767676), Colors.white),
        closeTo(4.54, 0.01),
      );
      expect(
        _referenceRatio(const Color(0xFFFF0000), Colors.white),
        closeTo(4.00, 0.01),
      );
      expect(
        _referenceRatio(const Color(0xFF0000FF), Colors.white),
        closeTo(8.59, 0.01),
      );
    });
  });

  group('collector matches the reference table within 0.1', () {
    const pairs = <(String, Color, Color)>[
      ('black on white', Colors.black, Colors.white),
      ('white on black', Colors.white, Colors.black),
      ('minimum-AA grey on white', Color(0xFF767676), Colors.white),
      ('mid grey on white (fails AA)', Color(0xFF808080), Colors.white),
      ('pure red on white', Color(0xFFFF0000), Colors.white),
      ('pure blue on white', Color(0xFF0000FF), Colors.white),
      ('dark green on white', Color(0xFF008000), Colors.white),
      ('white on brand blue', Colors.white, Color(0xFF0066CC)),
      ('black on yellow', Colors.black, Color(0xFFFFFF00)),
      ('near-black on near-white', Color(0xFF333333), Color(0xFFEEEEEE)),
      ('white on medium grey', Colors.white, Color(0xFF757575)),
      ('orange on black', Color(0xFFFFA500), Colors.black),
    ];

    for (final (name, foreground, background) in pairs) {
      testWidgets(name, (tester) async {
        await tester.pumpWidget(_pairScreen(foreground, background));

        final samples = await const RasterCollector().collect(tester);
        final sample = samples.firstWhere((s) => s.label == _sampleText);

        expect(
          sample.contrastRatio,
          closeTo(_referenceRatio(foreground, background), 0.1),
        );
      });
    }
  });

  group('adversarial abstention', () {
    testWidgets('well-contrasted text over a gradient is never a hard error', (
      tester,
    ) async {
      // White text over a dark-to-dark gradient: whichever colour the sampler
      // lands on, the true ratio is high everywhere. A hard contrast error
      // here would be a false positive by construction.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF001A66), Color(0xFF330044)],
                ),
              ),
              child: Center(
                child: Text(
                  'Over a gradient',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      );

      final report = await tester.auditAccessibility(textScales: const [1.0]);

      expect(
        report.findings.where(
          (f) => f.ruleId == 'attest/contrast' && f.severity == Severity.error,
        ),
        isEmpty,
      );
    });

    testWidgets('a disabled control is exempt even at a failing ratio', (
      tester,
    ) async {
      // Material paints disabled labels at ~38% opacity, which fails the
      // ratio on paper; WCAG 1.4.3 exempts disabled controls, so the
      // collector tags the sample and the rule must stay silent.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: TextButton(
                onPressed: null,
                child: Text('Disabled action'),
              ),
            ),
          ),
        ),
      );

      final report = await tester.auditAccessibility(textScales: const [1.0]);

      expect(
        report.findings.where((f) => f.ruleId == 'attest/contrast'),
        isEmpty,
      );
    });
  });

  group('overflow is scale-induced, not pre-existing', () {
    testWidgets('the fragile fixture fits at 1.0 and overflows at 2.0', (
      tester,
    ) async {
      await tester.pumpWidget(_overflowScreen(flexible: false));

      // Proof the violation is caused by scaling: no overflow at 1.0.
      expect(tester.takeException(), isNull);

      final observations = await const TextScaleCollector().collect(
        tester,
        const [1.0, 2.0],
      );

      final atTwo = observations.firstWhere((o) => o.textScale == 2.0);
      expect(atTwo.overflowed, isTrue);
    });

    testWidgets('the flexible variant survives both scales', (tester) async {
      await tester.pumpWidget(_overflowScreen(flexible: true));

      expect(tester.takeException(), isNull);

      final observations = await const TextScaleCollector().collect(
        tester,
        const [1.0, 2.0],
      );

      final atTwo = observations.firstWhere((o) => o.textScale == 2.0);
      expect(atTwo.overflowed, isFalse);
    });
  });

  group('contrast samples carry the semantics identifier', () {
    testWidgets('the nearest identifier is attached to the sample', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Semantics(
                identifier: 'ref.sample-text',
                child: const Text(
                  _sampleText,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      await tester.pump();
      final samples = await const RasterCollector().collect(tester);
      handle.dispose();

      final sample = samples.firstWhere((s) => s.label == _sampleText);
      expect(sample.identifier, 'ref.sample-text');
    });
  });
}
