// Auditing accessibility on a real device or desktop with integration_test.
//
// Run it against a connected device:
//
//   flutter test integration_test/accessibility_test.dart -d <device>
//
// This audits the *rendered* app — the same `tester.auditAccessibility()` API
// as a widget test, but on the real engine, so it sees native-semantics and
// platform-channel differences a widget test cannot, and real input focus
// exists. The tree-walking rules run on any binding; contrast reads the
// rendered layer (a debug build, which is the default here); the text-scale
// overflow pass relies on a test-only re-pump, so start with `textScales:
// [1.0]` on a live binding and widen it once you have validated it on your
// target.

import 'package:attest_flutter/attest_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void _noop() {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a screen is accessible on the real device', (tester) async {
    // Pump your real app here, e.g. `await tester.pumpWidget(const MyApp())`.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ElevatedButton(onPressed: _noop, child: Text('Pay')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final report = await tester.auditAccessibility(
      screenName: 'PaymentScreen',
      textScales: const [1.0],
    );

    expect(report, passesAccessibilityGate());
  });
}
