import 'package:meta/meta.dart';

import '../model/criterion.dart';
import '../model/finding.dart';
import '../model/standard.dart';
import 'coverage_matrix.dart';
import 'criterion_coverage.dart';

/// A machine-readable conformance document for one standard pack.
///
/// For every success criterion in the pack it records the coverage status, the
/// rules that cover it, attest's guidance, and the automated findings mapped to
/// that clause. It is the stable substrate a report, dashboard or VPAT/EU
/// accessibility statement is built from — a complete, clause-by-clause picture
/// rather than a bare findings list. [schemaVersion] is bumped only on a
/// breaking change to this shape.
@immutable
class ConformanceReport {
  /// Creates a [ConformanceReport].
  const ConformanceReport({
    required this.standard,
    required this.toolVersion,
    required this.generatedAt,
    required this.entries,
    this.toolName = 'attest',
    this.schemaVersion = '1',
  });

  /// Assembles a report for [standard] from the aggregated [findings].
  ///
  /// Findings are grouped onto the clause they cite; every criterion in the
  /// pack gets an entry, so manual clauses appear even with no findings.
  factory ConformanceReport.build({
    required Standard standard,
    required List<Finding> findings,
    required String toolVersion,
    DateTime? generatedAt,
  }) {
    final byWcag = <String, List<Finding>>{};
    for (final finding in findings) {
      byWcag.putIfAbsent(finding.criterion.wcag, () => []).add(finding);
    }
    final entries = [
      for (final row in CoverageMatrix.forStandard(standard).rows)
        ConformanceEntry(
          criterion: row.criterion,
          status: row.status,
          ruleIds: row.ruleIds,
          guidance: row.guidance,
          findings: List.unmodifiable(byWcag[row.criterion.wcag] ?? const []),
        ),
    ];
    return ConformanceReport(
      standard: standard,
      toolVersion: toolVersion,
      generatedAt: (generatedAt ?? DateTime.now()).toUtc(),
      entries: List.unmodifiable(entries),
    );
  }

  /// The version of this document's JSON shape.
  final String schemaVersion;

  /// The standard pack this report covers.
  final Standard standard;

  /// The tool that produced the report.
  final String toolName;

  /// The version of the tool that produced the report.
  final String toolVersion;

  /// When the report was produced (UTC).
  final DateTime generatedAt;

  /// One entry per success criterion in the pack, in criterion order.
  final List<ConformanceEntry> entries;

  /// The total number of automated findings across all clauses.
  int get findingCount =>
      entries.fold(0, (sum, entry) => sum + entry.findings.length);

  int _statusCount(CoverageStatus status) =>
      entries.where((entry) => entry.status == status).length;

  /// The JSON representation of this report.
  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'tool': {'name': toolName, 'version': toolVersion},
        'standard': standard.toJson(),
        'generatedAt': generatedAt.toIso8601String(),
        'summary': {
          'criteria': entries.length,
          'automated': _statusCount(CoverageStatus.automated),
          'partial': _statusCount(CoverageStatus.partial),
          'manual': _statusCount(CoverageStatus.manual),
          'findings': findingCount,
        },
        'criteria': [for (final entry in entries) entry.toJson()],
      };
}

/// One clause of a [ConformanceReport]: its coverage plus the findings on it.
@immutable
class ConformanceEntry {
  /// Creates a [ConformanceEntry].
  const ConformanceEntry({
    required this.criterion,
    required this.status,
    required this.ruleIds,
    required this.guidance,
    required this.findings,
  });

  /// The success criterion.
  final Criterion criterion;

  /// How far attest covers it.
  final CoverageStatus status;

  /// The rules that cover it, if any.
  final List<String> ruleIds;

  /// The own-words note on what attest checks or what a human must review.
  final String guidance;

  /// The automated findings mapped to this clause.
  final List<Finding> findings;

  /// Whether a human still needs to review this clause — anything not fully
  /// automated.
  bool get needsManualReview => status != CoverageStatus.automated;

  /// The JSON representation of this entry.
  Map<String, dynamic> toJson() => {
        'criterion': criterion.toJson(),
        'status': status.toJson(),
        if (ruleIds.isNotEmpty) 'ruleIds': ruleIds,
        'guidance': guidance,
        'needsManualReview': needsManualReview,
        'findingCount': findings.length,
        if (findings.isNotEmpty)
          'findings': [for (final finding in findings) finding.toJson()],
      };
}
