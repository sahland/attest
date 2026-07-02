/// Programmatic entry point for the `attest` command-line tool.
///
/// The CLI aggregates the per-screen JSON reports emitted by a widget-test run,
/// diffs them against a baseline by fingerprint, and renders text, JSON, SARIF
/// or HTML output. It never pumps widgets itself, which keeps it Flutter-free
/// and fast.
///
/// **The supported interface of this package is the command line** (`attest
/// ci`, `attest baseline`, `attest transcript`), which is stable under
/// semantic versioning. The Dart library surface exported here is plumbing for
/// the executable; it is annotated `@experimental` and may change in minor
/// releases.
library;

import 'package:args/command_runner.dart';
import 'package:meta/meta.dart';

import 'src/commands/baseline_command.dart';
import 'src/commands/ci_command.dart';
import 'src/commands/coverage_command.dart';
import 'src/commands/transcript_command.dart';

export 'src/commands/baseline_command.dart';
export 'src/commands/ci_command.dart';
export 'src/commands/coverage_command.dart';
export 'src/commands/transcript_command.dart';
export 'src/html_writer.dart';
export 'src/report_loader.dart';

/// Builds the `attest` command runner with the `ci`, `baseline`, `transcript`
/// and `coverage` commands.
@experimental
CommandRunner<int> buildAttestRunner() => CommandRunner<int>(
      'attest',
      'Aggregate attest reports, gate a baseline, and render output.',
    )
      ..addCommand(CiCommand())
      ..addCommand(BaselineCommand())
      ..addCommand(TranscriptCommand())
      ..addCommand(CoverageCommand());
