# attest_flutter

Flutter test integration for the [**attest**](https://github.com/sahland/attest)
accessibility-compliance toolkit. This package provides the developer-facing
entry point — `tester.auditAccessibility()` — plus the raster (contrast) and
text-scale (reflow/overflow) collectors and the gate matchers.

> **Honest framing.** Automated checks catch roughly 30–40% of accessibility
> issues. This tooling provides automated coverage of machine-checkable
> criteria plus a structured checklist for the rest. It does **not** certify
> "EAA compliance."

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

> The API above is the target surface; it is being built out (see the roadmap).

## Status

Early development. The public API is not yet stable.

## License

BSD-3-Clause.
