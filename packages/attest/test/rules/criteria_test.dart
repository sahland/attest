import 'package:attest/attest.dart';
import 'package:test/test.dart';

void main() {
  final criteria = {
    for (final rule in RuleEngine.standard().rules) rule.id: rule.criterion,
  };

  test('every bundled rule cites a criterion with an Understanding URL', () {
    for (final entry in criteria.entries) {
      final understanding = entry.value.understanding;
      expect(
        understanding,
        isNotNull,
        reason: '${entry.key} cites ${entry.value.wcag} with no Understanding '
            'URL — developers lose the "learn more" link.',
      );
      expect(
        understanding,
        startsWith('https://www.w3.org/WAI/WCAG22/Understanding/'),
        reason: '${entry.key}: Understanding URL should be a canonical W3C '
            'page, was "$understanding".',
      );
      expect(understanding, endsWith('.html'));
    }
  });

  test('the Understanding URL survives a criterion JSON round-trip', () {
    const criterion = Criterion(
      wcag: '1.4.3',
      wcagLevel: 'AA',
      en301549: '11.1.4.3',
      title: 'Contrast (Minimum)',
      understanding:
          'https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html',
    );
    expect(Criterion.fromJson(criterion.toJson()), criterion);
  });

  test('a criterion parsed from pre-URL JSON keeps a null Understanding', () {
    final restored = Criterion.fromJson(const {
      'wcag': '1.4.3',
      'wcagLevel': 'AA',
      'en301549': '11.1.4.3',
      'title': 'Contrast (Minimum)',
    });
    expect(restored.understanding, isNull);
  });
}
