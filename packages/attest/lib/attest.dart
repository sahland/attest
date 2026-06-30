/// Pure-Dart core of **attest**: the accessibility rule engine, data model,
/// reporting and baseline logic.
///
/// This library depends on nothing Flutter — every rule is a pure function over
/// a serializable [SemanticsSnapshot], so rules are unit-testable without a
/// widget tester. Flutter-specific collection lives in `attest_flutter`.
///
/// This barrel is the only supported entry point. Nothing under `src/` is
/// exported directly; import only `package:attest/attest.dart`.
library;

// The public API surface is exported here as the engine is built out; see the
// roadmap (M1 onwards). Intentionally empty during the M0 scaffold.
