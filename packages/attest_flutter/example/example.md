# Example

Audit a pumped screen inside an ordinary widget test:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:attest_flutter/attest_flutter.dart';

void main() {
  testWidgets('CheckoutScreen is accessible', (tester) async {
    await tester.pumpWidget(const MyApp(home: CheckoutScreen()));

    final report = await tester.auditAccessibility();

    expect(report, passesAccessibilityGate());
  });
}
```

When the gate fails, the matcher prints a grouped, criterion-tagged, source-
located summary — one entry per finding, each citing its WCAG success criterion
and EN 301 549 clause, with a concrete fix suggestion.

A full, runnable dogfood app with one broken screen per rule lives in the
[`example/`](https://github.com/sahland/attest/tree/main/example) directory at
the repository root.
