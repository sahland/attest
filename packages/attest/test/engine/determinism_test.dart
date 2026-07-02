import 'dart:convert';

import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';

/// Determinism and fingerprint stability at the whole-report level (Phase 1,
/// P1.6). Non-determinism silently corrupts the baseline gate, and fingerprint
/// stability is the load-bearing property of the diff — both are guarded here,
/// not assumed. Unit-level fingerprint properties live in `fingerprint_test`.
void main() {
  final meta = AuditMeta(
    screenName: 'DeterminismScreen',
    standard: 'en301549_v3_2_1',
    toolVersion: 'test',
    timestamp: DateTime.utc(2026),
  );

  /// A messy screen exercising many rules at once, optionally translated by
  /// ([dx], [dy]) and with the placeholder label swapped for [placeholder].
  SemanticsSnapshot messyScreen({
    double dx = 0,
    double dy = 0,
    String placeholder = 'button',
  }) {
    RectData at(double l, double t, double w, double h) =>
        rect(l + dx, t + dy, w, h);

    return snap(
      node(
        bounds: at(0, 0, 400, 800),
        children: [
          node(
            label: 'Your orders',
            textStyle: const TextStyleData(fontSize: 28),
            bounds: at(0, 0, 300, 40),
          ),
          node(flags: {isButton}, actions: {tap}, bounds: at(0, 60, 48, 48)),
          node(flags: {isImage}, bounds: at(60, 60, 100, 100)),
          node(
            flags: {isTextField},
            hint: 'Email',
            bounds: at(0, 180, 300, 48),
          ),
          node(
            label: placeholder,
            flags: {isButton},
            actions: {tap},
            bounds: at(0, 240, 120, 48),
          ),
          node(
            label: 'Delete',
            flags: {isButton},
            actions: {tap},
            bounds: at(0, 300, 100, 48),
          ),
          node(
            label: 'Delete',
            flags: {isButton},
            actions: {tap},
            bounds: at(120, 300, 100, 48),
          ),
          node(
            label: 'Menu',
            flags: {isButton, isHidden},
            actions: {tap},
            bounds: at(0, 360, 80, 48),
          ),
          node(
            bounds: at(0, 420, 300, 48),
            children: [
              node(label: 'Day', actions: {tap}, bounds: at(0, 420, 150, 48)),
              node(
                label: 'Week',
                actions: {tap},
                bounds: at(150, 420, 150, 48),
              ),
            ],
          ),
          node(
            bounds: at(0, 480, 300, 120),
            children: [
              node(label: 'below', bounds: at(0, 560, 100, 40)),
              node(label: 'above', bounds: at(0, 490, 100, 40)),
            ],
          ),
        ],
      ),
      contrastSamples: [
        ContrastSample(
          label: 'Subtitle',
          foregroundLuminance: 0.0,
          backgroundLuminance: 0.05,
          bounds: at(0, 620, 200, 20),
          fontSize: 14,
        ),
      ],
      textScaleObservations: const [
        TextScaleObservation(textScale: 2.0, overflowed: true),
      ],
    );
  }

  Set<String> fingerprintsOf(AuditReport report) =>
      report.findings.map((f) => f.fingerprint).toSet();

  test('the same input twice produces byte-identical output', () {
    final engine = RuleEngine.standard();
    final snapshot = messyScreen();

    final first = jsonEncode(engine.run(snapshot, meta: meta).toJson());
    final second = jsonEncode(engine.run(snapshot, meta: meta).toJson());

    expect(second, equals(first));
  });

  test('output does not depend on rule registration order', () {
    final snapshot = messyScreen();
    final forward = RuleEngine.standard();
    final backward = RuleEngine(forward.rules.reversed.toList());

    final a = jsonEncode(forward.run(snapshot, meta: meta).toJson());
    final b = jsonEncode(backward.run(snapshot, meta: meta).toJson());

    expect(b, equals(a));
  });

  test('a pure layout translation leaves every fingerprint unchanged', () {
    final engine = RuleEngine.standard();
    final original = engine.run(messyScreen(), meta: meta);
    final shifted = engine.run(messyScreen(dx: 137, dy: 211), meta: meta);

    expect(original.findings, isNotEmpty);
    expect(shifted.findings.length, original.findings.length);
    expect(fingerprintsOf(shifted), equals(fingerprintsOf(original)));
  });

  test('a genuine violation change moves the fingerprint', () {
    final engine = RuleEngine.standard();
    final original = fingerprintsOf(engine.run(messyScreen(), meta: meta));
    final changed = fingerprintsOf(
      engine.run(messyScreen(placeholder: 'icon'), meta: meta),
    );

    // The placeholder-name finding must have a new fingerprint; everything
    // else stays put, so the symmetric difference is exactly that one pair.
    expect(changed, isNot(equals(original)));
    expect(original.difference(changed), hasLength(1));
    expect(changed.difference(original), hasLength(1));
  });
}
