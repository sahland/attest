import 'dart:convert';
import 'dart:io';

import 'package:attest/attest.dart';
import 'package:meta/meta.dart';

/// Loads the per-screen JSON reports a test run emits.
@experimental
class ReportLoader {
  /// Creates a [ReportLoader].
  const ReportLoader();

  /// Reads every `*.json` report in [directoryPath], newest-screen order made
  /// deterministic by sorting on screen name. Returns an empty list if the
  /// directory does not exist.
  List<AuditReport> loadDirectory(String directoryPath) {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) return const [];

    final reports = <AuditReport>[];
    for (final entity in directory.listSync()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      final decoded =
          jsonDecode(entity.readAsStringSync()) as Map<String, dynamic>;
      reports.add(AuditReport.fromJson(decoded));
    }

    reports.sort((a, b) => a.meta.screenName.compareTo(b.meta.screenName));
    return reports;
  }
}

/// The findings across [reports], flattened in report order.
List<Finding> aggregateFindings(Iterable<AuditReport> reports) => [
      for (final report in reports) ...report.findings,
    ];
