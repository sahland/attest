/// The **attest** validation-corpus API.
///
/// This is a separate entry point from `package:attest/attest.dart` so the core
/// rule-engine surface stays focused. Import it to author labelled correctness
/// cases ([CorpusCase], [ExpectedFinding]) — the ground-truth data the
/// precision/recall harness measures each rule against.
///
/// A case is a lazily-built [SemanticsSnapshot] plus the findings a human
/// confirmed it should produce, anchored to semantics identifiers. See
/// `test/corpus/README.md` for the directory convention and how to add a case.
library;

export 'src/corpus/corpus_case.dart';
export 'src/corpus/metrics.dart';
