import '../model/standard.dart';
import 'criterion_coverage.dart';
import 'wcag_registry.dart';

/// The coverage matrix for one standard pack: every success criterion in scope,
/// classified as automated, partial or manual.
///
/// This is the honesty artifact that separates a compliance instrument from a
/// linter — it states, per clause, exactly what attest verifies and what a
/// human must still review. It adds no detection and so carries no
/// false-positive risk; it reads the [WcagRegistry].
class CoverageMatrix {
  const CoverageMatrix._(this.standard, this.rows);

  /// Builds the matrix for [standard], keeping only the criteria that pack
  /// includes (WCAG 2.2-only criteria are dropped from EN 301 549 v3.2.1).
  factory CoverageMatrix.forStandard(Standard standard) => CoverageMatrix._(
        standard,
        List.unmodifiable(
          WcagRegistry.all.where((r) => standard.includes(r.criterion)),
        ),
      );

  /// The pack this matrix describes.
  final Standard standard;

  /// Every criterion in the pack, in success-criterion order.
  final List<CriterionCoverage> rows;

  /// The rows with the given [status].
  Iterable<CriterionCoverage> withStatus(CoverageStatus status) =>
      rows.where((row) => row.status == status);

  /// How many criteria have the given [status].
  int count(CoverageStatus status) => withStatus(status).length;

  /// The total number of criteria in the pack.
  int get total => rows.length;

  /// The JSON representation: the pack, a summary, and every row.
  Map<String, dynamic> toJson() => {
        'standard': standard.toJson(),
        'summary': {
          for (final status in CoverageStatus.values)
            status.toJson(): count(status),
          'total': total,
        },
        'criteria': [for (final row in rows) row.toJson()],
      };

  /// A human-readable table, grouped by status.
  String renderTable() {
    final buffer = StringBuffer()
      ..writeln('Coverage matrix — ${standard.toJson()}')
      ..writeln(
        '${count(CoverageStatus.automated)} automated, '
        '${count(CoverageStatus.partial)} partial, '
        '${count(CoverageStatus.manual)} manual '
        '(of $total criteria)',
      )
      ..writeln();

    for (final status in CoverageStatus.values) {
      final group = withStatus(status).toList();
      if (group.isEmpty) continue;
      buffer.writeln('${status.toJson().toUpperCase()}:');
      for (final row in group) {
        final c = row.criterion;
        final rules = row.ruleIds.isEmpty ? '' : ' [${row.ruleIds.join(', ')}]';
        buffer
          ..writeln(
            '  ${c.wcag.padRight(7)} ${c.wcagLevel.padRight(2)} '
            '${c.title}$rules',
          )
          ..writeln('      ${row.guidance}');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}
