import 'package:attest_flutter/attest_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('maps labels, flags and actions from the live tree', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Pay'),
              ),
              Semantics(
                image: true,
                label: 'Revenue chart',
                child: const SizedBox(width: 24, height: 24),
              ),
              const SizedBox(width: 200, child: TextField()),
            ],
          ),
        ),
      ),
    );

    final handle = tester.ensureSemantics();
    await tester.pump();
    final root = tester
        .binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!;
    final snapshot = const SemanticsSnapshotBuilder().build(root);
    handle.dispose();

    final nodes = snapshot.allNodes.toList();

    expect(
      nodes.any(
        (n) =>
            n.label == 'Pay' &&
            n.hasFlag(SemanticsFlagData.isButton) &&
            n.hasAction(SemanticsActionData.tap),
      ),
      isTrue,
      reason: 'expected a named button node',
    );
    expect(
      nodes.any(
        (n) =>
            n.hasFlag(SemanticsFlagData.isImage) && n.label == 'Revenue chart',
      ),
      isTrue,
      reason: 'expected a labelled image node',
    );
    expect(
      nodes.any((n) => n.hasFlag(SemanticsFlagData.isTextField)),
      isTrue,
      reason: 'expected a text field node',
    );
  });
}
