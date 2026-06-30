// Demonstrates the pure-Dart engine: build a snapshot, run the bundled rules,
// and print the findings. No Flutter required.
//
// ignore_for_file: avoid_print

import 'package:attest/attest.dart';

void main() {
  // A tiny hand-built snapshot: a single button with no accessible name.
  const snapshot = SemanticsSnapshot(
    root: SemanticsNodeData(
      id: 0,
      childrenInTraversalOrder: [
        SemanticsNodeData(
          id: 1,
          flags: {SemanticsFlagData.isButton},
          actions: {SemanticsActionData.tap},
        ),
      ],
    ),
  );

  final report = RuleEngine.standard().run(
    snapshot,
    meta: AuditMeta(
      screenName: 'Example',
      standard: 'en301549_v3_2_1',
      toolVersion: '0.1.0',
      timestamp: DateTime.now().toUtc(),
    ),
  );

  for (final finding in report.findings) {
    print('${finding.ruleId} (WCAG ${finding.criterion.wcag}): '
        '${finding.message}');
  }
  print('passes: ${report.passes}');
}
