import 'package:attest_example/screens.dart';
import 'package:attest_flutter/attest_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<AuditReport> audit(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(MaterialApp(home: screen));
    return tester.auditAccessibility(screenName: screen.runtimeType.toString());
  }

  Set<String> ruleIds(AuditReport report) =>
      report.findings.map((f) => f.ruleId).toSet();

  testWidgets('each broken screen reports exactly its catalogued defect', (
    tester,
  ) async {
    expect(
      ruleIds(await audit(tester, const BrokenInteractiveNameScreen())),
      {'attest/interactive-name'},
    );
    expect(
      ruleIds(await audit(tester, const BrokenImageAltScreen())),
      {'attest/image-alt'},
    );
    expect(
      ruleIds(await audit(tester, const BrokenPlaceholderNameScreen())),
      {'attest/placeholder-name'},
    );
    expect(
      ruleIds(await audit(tester, const BrokenFieldLabelScreen())),
      {'attest/field-label'},
    );
    expect(
      ruleIds(await audit(tester, const BrokenTargetSizeScreen())),
      {'attest/target-size'},
    );
    expect(
      ruleIds(await audit(tester, const BrokenFocusTrapScreen())),
      {'attest/focus-trap'},
    );
    expect(
      ruleIds(await audit(tester, const BrokenAmbiguousNameScreen())),
      {'attest/ambiguous-name'},
    );
  });

  testWidgets('the clean screen has no violations', (tester) async {
    final report = await audit(tester, const CleanScreen());
    expect(report, hasNoAccessibilityViolations());
    expect(report, passesAccessibilityGate());
  });
}
