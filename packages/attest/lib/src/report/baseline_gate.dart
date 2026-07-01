import '../model/finding.dart';
import 'baseline.dart';

/// The outcome of diffing a run's findings against a [Baseline].
class GateResult {
  /// Creates a [GateResult].
  const GateResult({
    required this.newFindings,
    required this.knownFindings,
    required this.resolvedFingerprints,
  });

  /// Findings whose fingerprint is not in the baseline — the regressions that
  /// fail the gate.
  final List<Finding> newFindings;

  /// Findings whose fingerprint is already accepted in the baseline.
  final List<Finding> knownFindings;

  /// Baseline fingerprints no longer produced by the run — candidates to prune
  /// from the baseline.
  final Set<String> resolvedFingerprints;

  /// Whether the run introduced no new findings.
  bool get passed => newFindings.isEmpty;
}

/// Diffs a run's findings against a [Baseline] by fingerprint.
///
/// The diff is pure set arithmetic — `new = current − baseline` — which is why
/// fingerprint stability is the property the whole gate rests on.
class BaselineGate {
  /// Creates a gate for [baseline].
  const BaselineGate(this.baseline);

  /// The accepted baseline.
  final Baseline baseline;

  /// Partitions [findings] into new, known and resolved relative to the
  /// baseline.
  GateResult evaluate(Iterable<Finding> findings) {
    final newFindings = <Finding>[];
    final knownFindings = <Finding>[];
    final seen = <String>{};

    for (final finding in findings) {
      seen.add(finding.fingerprint);
      if (baseline.contains(finding.fingerprint)) {
        knownFindings.add(finding);
      } else {
        newFindings.add(finding);
      }
    }

    return GateResult(
      newFindings: newFindings,
      knownFindings: knownFindings,
      resolvedFingerprints: baseline.fingerprints.difference(seen),
    );
  }
}
