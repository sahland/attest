import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:attest/attest.dart';
import 'package:meta/meta.dart';

import '../html_writer.dart';
import '../report_loader.dart';

/// `attest ci`: aggregate reports, diff the baseline, and exit non-zero when the
/// run introduces new findings.
@experimental
class CiCommand extends Command<int> {
  /// Creates the `ci` command.
  CiCommand() {
    argParser
      ..addOption(
        'report-dir',
        defaultsTo: 'build/a11y',
        help: 'Directory of per-screen JSON reports.',
      )
      ..addOption(
        'baseline',
        defaultsTo: '.a11y/baseline.json',
        help: 'Baseline file to diff against.',
      )
      ..addOption(
        'format',
        allowed: ['text', 'json', 'sarif', 'html', 'conformance'],
        defaultsTo: 'text',
        help: 'Output format.',
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Write output to this file instead of stdout.',
      );
  }

  @override
  String get name => 'ci';

  @override
  String get description =>
      'Aggregate reports, diff the baseline, and exit non-zero on new findings.';

  @override
  Future<int> run() async {
    final args = argResults!;
    final reports = const ReportLoader().loadDirectory(
      args.option('report-dir')!,
    );
    final gate = BaselineGate(
      _loadBaseline(args.option('baseline')!),
    ).evaluate(aggregateFindings(reports));

    final rendered = _render(args.option('format')!, reports, gate);
    final outputPath = args.option('output');
    if (outputPath == null) {
      stdout.writeln(rendered);
    } else {
      File(outputPath)
        ..createSync(recursive: true)
        ..writeAsStringSync(rendered);
    }

    if (!gate.passed) {
      stderr.writeln(
        'attest: ${gate.newFindings.length} new accessibility finding(s).',
      );
      return 1;
    }
    return 0;
  }

  Baseline _loadBaseline(String path) {
    final file = File(path);
    if (!file.existsSync()) return Baseline.empty;
    return Baseline.fromJson(
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
    );
  }

  String _render(String format, List<AuditReport> reports, GateResult gate) {
    switch (format) {
      case 'json':
        return const JsonEncoder.withIndent('  ').convert({
          'passed': gate.passed,
          'new': [for (final f in gate.newFindings) f.toJson()],
          'known': [for (final f in gate.knownFindings) f.toJson()],
          'resolved': gate.resolvedFingerprints.toList()..sort(),
        });
      case 'sarif':
        final version =
            reports.isEmpty ? '0.0.0' : reports.first.meta.toolVersion;
        return const JsonEncoder.withIndent('  ').convert(
          SarifWriter(toolVersion: version).write(reports),
        );
      case 'html':
        return const HtmlWriter().write(reports, gate);
      case 'conformance':
        final version =
            reports.isEmpty ? '0.0.0' : reports.first.meta.toolVersion;
        return const JsonEncoder.withIndent('  ').convert(
          ConformanceReport.build(
            standard: _packOf(reports),
            findings: aggregateFindings(reports),
            toolVersion: version,
          ).toJson(),
        );
      case 'text':
      default:
        return _text(gate);
    }
  }

  /// The standard pack the [reports] were audited under, defaulting to
  /// EN 301 549 v3.2.1 when it cannot be read.
  Standard _packOf(List<AuditReport> reports) {
    for (final report in reports) {
      try {
        return Standard.fromJson(report.meta.standard);
      } on ArgumentError {
        continue;
      }
    }
    return Standard.en301549_v3_2_1;
  }

  String _text(GateResult gate) {
    if (gate.passed) {
      return 'No new accessibility findings '
          '(${gate.knownFindings.length} known).';
    }
    final buffer = StringBuffer()
      ..writeln('${gate.newFindings.length} new accessibility finding(s):')
      ..writeln();
    for (final finding in gate.newFindings) {
      buffer
        ..writeln('  ✗ [${finding.severity.name}] ${finding.ruleId} — '
            '${finding.criterion}')
        ..writeln('    ${finding.message}');
      if (finding.location != null) {
        buffer.writeln('    ${finding.location}');
      }
      buffer.writeln('    Fix: ${finding.suggestion}');
      final understanding = finding.criterion.understanding;
      if (understanding != null) {
        buffer.writeln('    Learn: $understanding');
      }
      buffer.writeln();
    }
    return buffer.toString().trimRight();
  }
}
