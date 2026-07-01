import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';
import '../support/matchers.dart';

void main() {
  const rule = HeadingStructureRule();

  test('flags large bold text when nothing is a header', () {
    final snapshot = snap(
      node(
        label: 'Your orders',
        textStyle: const TextStyleData(fontSize: 28, fontWeight: 700),
      ),
    );
    expect(
      evaluate(rule, snapshot),
      hasFinding('attest/heading-structure', wcag: '1.3.1'),
    );
  });

  test('stays silent once any node is a header', () {
    final snapshot = snap(
      node(
        children: [
          node(label: 'Title', flags: {isHeader}),
          node(
            label: 'Your orders',
            textStyle: const TextStyleData(fontSize: 28, fontWeight: 700),
          ),
        ],
      ),
    );
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('does not flag body-sized text', () {
    final snapshot = snap(
      node(
        label: 'Some body copy',
        textStyle: const TextStyleData(fontSize: 14),
      ),
    );
    expect(evaluate(rule, snapshot), isEmpty);
  });

  test('does not flag text with no style information', () {
    expect(evaluate(rule, snap(node(label: 'Plain'))), isEmpty);
  });
}
