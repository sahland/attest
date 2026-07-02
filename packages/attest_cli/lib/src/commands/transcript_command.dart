import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:meta/meta.dart';

import '../report_loader.dart';

/// `attest transcript`: print the screen-reader transcript for each audited
/// screen — the sequence of announcements TalkBack or VoiceOver would make.
@experimental
class TranscriptCommand extends Command<int> {
  /// Creates the `transcript` command.
  TranscriptCommand() {
    argParser.addOption(
      'report-dir',
      defaultsTo: 'build/a11y',
      help: 'Directory of per-screen JSON reports.',
    );
  }

  @override
  String get name => 'transcript';

  @override
  String get description =>
      'Print the screen-reader transcript for each audited screen.';

  @override
  Future<int> run() async {
    final args = argResults!;
    final reports = const ReportLoader().loadDirectory(
      args.option('report-dir')!,
    );

    if (reports.isEmpty) {
      stderr.writeln(
        'attest: no reports found in ${args.option('report-dir')}.',
      );
      return 0;
    }

    for (final report in reports) {
      stdout.writeln('── ${report.meta.screenName} ──');
      if (report.transcript.isEmpty) {
        stdout.writeln(
          '  (no transcript; run auditAccessibility with transcript enabled)',
        );
      } else {
        for (var i = 0; i < report.transcript.length; i++) {
          stdout.writeln('  ${i + 1}. ${report.transcript[i]}');
        }
      }
      stdout.writeln();
    }
    return 0;
  }
}
