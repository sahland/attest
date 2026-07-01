import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:attest/attest.dart';

import '../report_loader.dart';

/// `attest baseline --update`: accept the current findings as the new baseline.
class BaselineCommand extends Command<int> {
  /// Creates the `baseline` command.
  BaselineCommand() {
    argParser
      ..addFlag(
        'update',
        negatable: false,
        help: 'Rewrite the baseline from the current reports.',
      )
      ..addOption(
        'report-dir',
        defaultsTo: 'build/a11y',
        help: 'Directory of per-screen JSON reports.',
      )
      ..addOption(
        'baseline',
        defaultsTo: '.a11y/baseline.json',
        help: 'Baseline file to write.',
      );
  }

  @override
  String get name => 'baseline';

  @override
  String get description => 'Manage the accepted-findings baseline.';

  @override
  Future<int> run() async {
    final args = argResults!;
    if (!args.flag('update')) {
      stderr.writeln('attest baseline: pass --update to rewrite the baseline.');
      return 64;
    }

    final reports = const ReportLoader().loadDirectory(
      args.option('report-dir')!,
    );
    final baseline = Baseline.fromFindings(aggregateFindings(reports));
    final path = args.option('baseline')!;

    File(path)
      ..createSync(recursive: true)
      ..writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(baseline.toJson())}\n',
      );

    stdout.writeln(
      'attest: wrote ${baseline.fingerprints.length} fingerprint(s) to $path.',
    );
    return 0;
  }
}
