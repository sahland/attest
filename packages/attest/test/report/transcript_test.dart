import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';

void main() {
  const generator = TranscriptGenerator();

  test('announces nodes in traversal order with role, state and hint', () {
    final snapshot = snap(
      node(
        children: [
          node(label: 'Your orders', flags: {isHeader}),
          node(label: 'Pay', flags: {isButton}, actions: {tap}),
          node(label: 'Revenue chart', flags: {isImage}),
          node(
            label: 'Email',
            flags: {isTextField},
            hint: 'Enter your email',
          ),
        ],
      ),
    );

    expect(generator.generate(snapshot), [
      'Your orders, heading',
      'Pay, button',
      'Revenue chart, image',
      'Email, edit box, Enter your email',
    ]);
  });

  test('announces control state', () {
    final snapshot = snap(
      node(
        children: [
          node(
            label: 'Subscribe',
            flags: {hasCheckedState, isChecked},
            actions: {tap},
          ),
          node(label: 'Wi-Fi', flags: {hasToggledState}, actions: {tap}),
        ],
      ),
    );

    expect(generator.generate(snapshot), [
      'Subscribe, checkbox, checked',
      'Wi-Fi, switch, off',
    ]);
  });

  test('skips hidden and empty nodes', () {
    final snapshot = snap(
      node(
        children: [
          node(label: 'Visible'),
          node(label: 'Ghost', flags: {isButton, isHidden}, actions: {tap}),
          node(),
        ],
      ),
    );

    expect(generator.generate(snapshot), ['Visible']);
  });

  test('travels through the report JSON', () {
    final report = AuditReport(
      findings: const [],
      meta: AuditMeta(
        screenName: 'S',
        standard: 'en301549_v3_2_1',
        toolVersion: '0.1.0',
        timestamp: DateTime.utc(2026),
      ),
      transcript: const ['Pay, button'],
    );
    expect(AuditReport.fromJson(report.toJson()).transcript, ['Pay, button']);
  });
}
