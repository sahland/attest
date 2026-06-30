import 'package:attest/attest.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';

void main() {
  group('Fingerprinter', () {
    test('is deterministic for identical inputs', () {
      String fp() => Fingerprinter.compute(
            ruleId: 'attest/x',
            wcag: '1.1.1',
            nodePath: 'node/button:0',
            label: 'Pay',
          );
      expect(fp(), equals(fp()));
    });

    test('ignores cosmetic label differences', () {
      final a = Fingerprinter.compute(
        ruleId: 'attest/x',
        wcag: '1.1.1',
        nodePath: 'button',
        label: '  Pay  ',
      );
      final b = Fingerprinter.compute(
        ruleId: 'attest/x',
        wcag: '1.1.1',
        nodePath: 'button',
        label: 'pay',
      );
      expect(a, equals(b));
    });

    test('changes when the structural path changes', () {
      final a = Fingerprinter.compute(
        ruleId: 'attest/x',
        wcag: '1.1.1',
        nodePath: 'button',
        label: 'Pay',
      );
      final b = Fingerprinter.compute(
        ruleId: 'attest/x',
        wcag: '1.1.1',
        nodePath: 'node/button:0',
        label: 'Pay',
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('finding fingerprints', () {
    const rule = PlaceholderNameRule();

    Finding only(SemanticsSnapshot s) => evaluate(rule, s).single;

    test('are stable under a pure layout shift', () {
      final near = only(
        snap(
          node(
            flags: {isButton},
            actions: {tap},
            label: 'button',
            bounds: rect(0, 0, 48, 48),
          ),
        ),
      );
      final far = only(
        snap(
          node(
            flags: {isButton},
            actions: {tap},
            label: 'button',
            bounds: rect(300, 700, 48, 48),
          ),
        ),
      );
      expect(near.fingerprint, equals(far.fingerprint));
    });

    test('differ when the offending label differs', () {
      final a =
          only(snap(node(flags: {isButton}, actions: {tap}, label: 'button')));
      final b = only(snap(node(flags: {isImage}, label: 'image')));
      expect(a.fingerprint, isNot(equals(b.fingerprint)));
    });

    test('differ when the node moves to a different depth', () {
      final shallow = only(
        snap(node(flags: {isButton}, actions: {tap}, label: 'button')),
      );
      final deep = only(
        snap(
          node(
            children: [
              node(flags: {isButton}, actions: {tap}, label: 'button'),
            ],
          ),
        ),
      );
      expect(shallow.fingerprint, isNot(equals(deep.fingerprint)));
    });
  });
}
