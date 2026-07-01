/// Programmatic entry point for the `attest` command-line tool.
///
/// The CLI aggregates the per-screen JSON reports emitted by a widget-test run,
/// diffs them against a baseline by fingerprint, and renders text, JSON, SARIF
/// or HTML output. It never pumps widgets itself, which keeps it Flutter-free
/// and fast.
library;

import 'package:args/command_runner.dart';

import 'src/commands/baseline_command.dart';
import 'src/commands/ci_command.dart';

export 'src/commands/baseline_command.dart';
export 'src/commands/ci_command.dart';
export 'src/html_writer.dart';
export 'src/report_loader.dart';

/// Builds the `attest` command runner with the `ci` and `baseline` commands.
CommandRunner<int> buildAttestRunner() => CommandRunner<int>(
      'attest',
      'Aggregate attest reports, gate a baseline, and render output.',
    )
      ..addCommand(CiCommand())
      ..addCommand(BaselineCommand());
