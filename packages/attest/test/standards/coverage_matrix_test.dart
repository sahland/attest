import 'package:attest/attest.dart';
import 'package:test/test.dart';

void main() {
  final engine = RuleEngine.standard();
  final ruleIds = engine.rules.map((r) => r.id).toSet();

  CriterionCoverage? rowFor(String wcag) {
    for (final row in WcagRegistry.all) {
      if (row.criterion.wcag == wcag) return row;
    }
    return null;
  }

  group('registry integrity', () {
    test('success-criterion numbers are unique', () {
      final numbers = WcagRegistry.all.map((r) => r.criterion.wcag).toList();
      expect(numbers.toSet(), hasLength(numbers.length));
    });

    test('every EN clause follows the 11.<sc> mirror', () {
      for (final row in WcagRegistry.all) {
        expect(row.criterion.en301549, '11.${row.criterion.wcag}');
      }
    });

    test('only Level A and AA criteria are listed', () {
      for (final row in WcagRegistry.all) {
        expect(['A', 'AA'], contains(row.criterion.wcagLevel));
      }
    });

    test('automated/partial rows name rules; manual rows name none', () {
      for (final row in WcagRegistry.all) {
        if (row.status == CoverageStatus.manual) {
          expect(row.ruleIds, isEmpty, reason: row.criterion.wcag);
        } else {
          expect(row.ruleIds, isNotEmpty, reason: row.criterion.wcag);
        }
      }
    });

    test('every rule id in the registry is a real engine rule', () {
      for (final row in WcagRegistry.all) {
        for (final id in row.ruleIds) {
          expect(ruleIds, contains(id), reason: '${row.criterion.wcag} -> $id');
        }
      }
    });
  });

  group('rules and registry agree', () {
    test('every bundled rule maps to an automated or partial criterion', () {
      for (final rule in engine.rules) {
        final row = rowFor(rule.criterion.wcag);
        expect(
          row,
          isNotNull,
          reason: '${rule.id} cites ${rule.criterion.wcag}',
        );
        expect(row!.status, isNot(CoverageStatus.manual), reason: rule.id);
        expect(row.ruleIds, contains(rule.id), reason: rule.id);
        // The registry's criterion must match what the rule actually cites.
        expect(row.criterion, rule.criterion, reason: rule.id);
      }
    });
  });

  group('CoverageMatrix per pack', () {
    test('EN 301 549 v3.2.1 drops the WCAG 2.2-only criteria', () {
      final matrix = CoverageMatrix.forStandard(Standard.en301549_v3_2_1);
      final numbers = matrix.rows.map((r) => r.criterion.wcag);
      expect(numbers, isNot(contains('2.5.8'))); // Target Size, new in 2.2
      expect(numbers, contains('1.4.3')); // Contrast, in 2.1
    });

    test('WCAG 2.2 is a superset of EN 301 549 v3.2.1', () {
      final en = CoverageMatrix.forStandard(Standard.en301549_v3_2_1);
      final wcag22 = CoverageMatrix.forStandard(Standard.wcag22);
      expect(wcag22.total, greaterThan(en.total));
      expect(wcag22.rows.map((r) => r.criterion.wcag), contains('2.5.8'));
    });

    test('the summary counts add up to the total', () {
      final matrix = CoverageMatrix.forStandard(Standard.wcag22);
      final sum = matrix.count(CoverageStatus.automated) +
          matrix.count(CoverageStatus.partial) +
          matrix.count(CoverageStatus.manual);
      expect(sum, matrix.total);
    });

    test('at least the thirteen rules back automated/partial criteria', () {
      final matrix = CoverageMatrix.forStandard(Standard.wcag22);
      final covered = {
        for (final row in matrix.rows)
          if (row.isAutomated) ...row.ruleIds,
      };
      expect(covered, containsAll(ruleIds));
    });

    test('every criterion round-trips its JSON status', () {
      final matrix = CoverageMatrix.forStandard(Standard.wcag22);
      final json = matrix.toJson();
      expect(json['summary'], isA<Map<String, dynamic>>());
      expect((json['criteria'] as List).length, matrix.total);
    });

    test('the rendered table includes each criterion and its guidance', () {
      final table = CoverageMatrix.forStandard(
        Standard.en301549_v3_2_1,
      ).renderTable();
      expect(table, contains('1.4.1'));
      expect(table, contains('Use of Color'));
      expect(table, contains('Colour must not be the only way'));
    });
  });
}
