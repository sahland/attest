import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:attest_cli/attest_cli.dart';

Future<void> main(List<String> args) async {
  final runner = buildAttestRunner();
  try {
    final code = await runner.run(args);
    exit(code ?? 0);
  } on UsageException catch (error) {
    stderr.writeln(error);
    exit(64);
  }
}
