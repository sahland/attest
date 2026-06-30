import 'dart:io';

import 'package:args/command_runner.dart';

Future<void> main(List<String> args) async {
  final runner = CommandRunner<int>(
    'attest',
    'Aggregate attest reports, gate a baseline, and render output.',
  );

  // The `ci`, `baseline` and `transcript` commands are registered here as they
  // are implemented (see the roadmap, M6 onwards).

  try {
    final code = await runner.run(args);
    exit(code ?? 0);
  } on UsageException catch (error) {
    stderr.writeln(error);
    exit(64);
  }
}
