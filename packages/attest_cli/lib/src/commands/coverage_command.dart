import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:attest/attest.dart';
import 'package:meta/meta.dart';

/// `attest coverage`: print the coverage matrix for a standard pack — which
/// WCAG clauses attest checks automatically and which require human review.
@experimental
class CoverageCommand extends Command<int> {
  /// Creates the `coverage` command.
  CoverageCommand() {
    argParser
      ..addOption(
        'standard',
        allowed: [for (final s in Standard.values) s.toJson()],
        defaultsTo: Standard.en301549_v3_2_1.toJson(),
        help: 'The standard pack to describe.',
      )
      ..addOption(
        'format',
        allowed: ['text', 'json'],
        defaultsTo: 'text',
        help: 'Output format.',
      );
  }

  @override
  String get name => 'coverage';

  @override
  String get description =>
      'Print which WCAG clauses attest covers automatically vs. manually.';

  @override
  Future<int> run() async {
    final args = argResults!;
    final standard = Standard.fromJson(args.option('standard')!);
    final matrix = CoverageMatrix.forStandard(standard);

    if (args.option('format') == 'json') {
      stdout
          .writeln(const JsonEncoder.withIndent('  ').convert(matrix.toJson()));
    } else {
      stdout.write(matrix.renderTable());
    }
    return 0;
  }
}
