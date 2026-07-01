// Standard-pack identifiers encode official version numbers, so their names use
// underscores rather than camelCase.
// ignore_for_file: constant_identifier_names

import 'criterion.dart';

/// A versioned pack of success criteria the audit runs against.
///
/// Selecting a pack filters the active rules to those whose cited criterion
/// belongs to it, so switching standards changes both the checks that run and
/// the criteria cited in the output.
enum Standard {
  /// EN 301 549 v3.2.1, which incorporates WCAG 2.1 Level AA. The default and
  /// the current EU legal baseline.
  en301549_v3_2_1,

  /// WCAG 2.2 Level AA — the basis for the forthcoming EN 301 549 v4.1.1.
  wcag22;

  /// Success criteria introduced in WCAG 2.2, and therefore absent from
  /// WCAG 2.1 / EN 301 549 v3.2.1.
  static const Set<String> _wcag22Only = {
    '2.4.11',
    '2.4.12',
    '2.4.13',
    '2.5.7',
    '2.5.8',
    '3.2.6',
    '3.3.7',
    '3.3.8',
    '3.3.9',
  };

  /// Whether this pack includes [criterion]. WCAG 2.2 is a superset, so it
  /// includes everything; EN 301 549 v3.2.1 (WCAG 2.1) excludes criteria that
  /// are new in 2.2.
  bool includes(Criterion criterion) =>
      this == Standard.wcag22 || !_wcag22Only.contains(criterion.wcag);

  /// Parses a [Standard] from its [name].
  static Standard fromJson(String json) => Standard.values.byName(json);

  /// The JSON representation of this standard (its [name]).
  String toJson() => name;
}
