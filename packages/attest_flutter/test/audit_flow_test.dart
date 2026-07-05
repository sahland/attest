import 'package:attest_flutter/attest_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A screen whose only accessibility defect lives inside a dialog: an unnamed
/// icon button that a static, single-screen audit never sees.
class _FlowApp extends StatelessWidget {
  const _FlowApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Rate us'),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.star)),
                  ],
                ),
              ),
            ),
            child: const Text('Open dialog'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('auditFlow catches a defect that only appears after a step', (
    tester,
  ) async {
    await tester.pumpWidget(const _FlowApp());

    final reports = await tester.auditFlow(
      screenName: 'Rating',
      textScales: const [1.0],
      contrast: false,
      steps: [
        AuditStep('open dialog', (t) async {
          await t.tap(find.text('Open dialog'));
          await t.pumpAndSettle();
        }),
      ],
    );

    expect(reports, hasLength(2));

    // The initial screen has no unnamed interactive element.
    expect(
      reports.first.findings.where(
        (f) => f.ruleId == 'attest/interactive-name',
      ),
      isEmpty,
    );

    // Opening the dialog reveals the unnamed icon button.
    expect(
      reports.last.findings.map((f) => f.ruleId),
      contains('attest/interactive-name'),
    );

    // Each report is labelled with its step.
    expect(reports.first.meta.screenName, 'Rating · initial');
    expect(reports.last.meta.screenName, 'Rating · open dialog');
  });

  testWidgets('a flow with no steps audits just the initial screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Hello'))),
    );

    final reports = await tester.auditFlow(
      steps: const [],
      textScales: const [1.0],
      contrast: false,
    );

    expect(reports, hasLength(1));
    expect(reports.single.meta.screenName, 'flow · initial');
  });
}
