import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';
import '../support/matchers.dart';

void main() {
  const rule = ImageAltRule();

  test('flags an image with no label', () {
    final snapshot = snap(node(flags: {isImage}));
    expect(
      evaluate(rule, snapshot),
      hasFinding('attest/image-alt', wcag: '1.1.1'),
    );
  });

  test('accepts an image with a label', () {
    final snapshot = snap(node(flags: {isImage}, label: 'Revenue chart'));
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('does not flag an interactive image (left to interactive-name)', () {
    final snapshot = snap(node(flags: {isImage}, actions: {tap}));
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('does not flag a non-image node with no label', () {
    final snapshot = snap(node(flags: {isButton}, actions: {tap}));
    expect(evaluate(rule, snapshot), isEmpty);
  });
}
