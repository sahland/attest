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
      )
      ..addOption(
        'history',
        help: 'Append this run to a JSON trend log at this path and show the '
            'change since the previous run.',
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

    final trend = _recordTrend(args.option('history'), gate);

    final rendered = _render(args.option('format')!, reports, gate, trend);
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

  /// Appends this run to the trend log at [path] (creating it if absent) and
  /// returns the change since the previous run. Returns null when no
  /// `--history` path was given.
  RunDelta? _recordTrend(String? path, GateResult gate) {
    if (path == null) return null;
    final file = File(path);
    final log = file.existsSync()
        ? TrendLog.fromJson(
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
          )
        : TrendLog.empty;
    final updated = log.append(
      summarizeRun(gate, timestamp: DateTime.now().toUtc()),
    );
    file
      ..createSync(recursive: true)
      ..writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(updated.toJson()),
      );
    return updated.latestDelta;
  }

  String _render(
    String format,
    List<AuditReport> reports,
    GateResult gate,
    RunDelta? trend,
  ) {
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
        return const HtmlWriter().write(reports, gate, trend: trend);
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
        return _text(gate, trend);
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

  String _text(GateResult gate, RunDelta? trend) {
    final trendLine = trend == null ? '' : '${_trendLine(trend)}\n';
    if (gate.passed) {
      return '${trendLine}No new accessibility findings '
          '(${gate.knownFindings.length} known).';
    }
    final buffer = StringBuffer()
      ..write(trendLine)
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
      final code = finding.codeExample;
      if (code != null) {
        for (final line in code.split('\n')) {
          buffer.writeln('      $line');
        }
      }
      final understanding = finding.criterion.understanding;
      if (understanding != null) {
        buffer.writeln('    Learn: $understanding');
      }
      buffer.writeln();
    }
    return buffer.toString().trimRight();
  }

  /// A one-line trend summary, e.g. `Trend: 8 findings (down 2 since last
  /// run).` or, for the first recorded run, `Trend: 8 findings (first run).`.
  static String _trendLine(RunDelta trend) {
    final total = trend.current.total;
    final noun = total == 1 ? 'finding' : 'findings';
    if (!trend.hasPrevious) {
      return 'Trend: $total $noun (first recorded run).';
    }
    final change = trend.totalDelta;
    final direction = change == 0
        ? 'no change'
        : change < 0
            ? 'down ${-change}'
            : 'up $change';
    return 'Trend: $total $noun ($direction since last run).';
  }
}
