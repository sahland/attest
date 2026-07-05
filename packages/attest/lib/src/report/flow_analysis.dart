import 'package:meta/meta.dart';

import '../model/audit_report.dart';
import '../model/finding.dart';

/// One step of a [FlowAnalysis]: a report plus what changed since the previous
/// report in the flow.
///
/// [introduced] are findings whose fingerprint was not present in the previous
/// step — the accessibility issues this interaction brought about. [resolved]
/// are fingerprints that were present before and are now gone.
@immutable
class StepDelta {
  /// Creates a [StepDelta].
  const StepDelta({
    required this.report,
    required this.introduced,
    required this.resolved,
  });

  /// The audit report for this step.
  final AuditReport report;

  /// Findings this step introduced (absent from the previous step).
  final List<Finding> introduced;

  /// Fingerprints of findings this step resolved (present before, gone now).
  final List<String> resolved;

  /// Whether this step introduced any new finding.
  bool get introducesFindings => introduced.isNotEmpty;

  /// The JSON representation of this delta.
  Map<String, dynamic> toJson() => {
        'screenName': report.meta.screenName,
        'introduced': [for (final finding in introduced) finding.toJson()],
        if (resolved.isNotEmpty) 'resolved': resolved,
      };
}

/// Diffs an ordered sequence of audit reports — typically the output of
/// `tester.auditFlow` — so each step's *introduced* and *resolved* findings are
/// explicit.
///
/// **Experimental.** This is what makes interaction-aware auditing actionable:
/// instead of "here are N reports", it says "opening the dialog introduced these
/// two issues". Matching is by the stable fingerprint, the same unit the
/// baseline gate uses, so a pure layout shift between steps does not register as
/// a change. Part of the young flow API and exempt from the 1.0 stability
/// promise.
@immutable
class FlowAnalysis {
  /// Creates a [FlowAnalysis] from its per-step [steps].
  const FlowAnalysis(this.steps);

  /// Diffs [reports] in order (the first is the baseline; it introduces all of
  /// its own findings and resolves none).
  factory FlowAnalysis.of(List<AuditReport> reports) {
    final deltas = <StepDelta>[];
    var previous = <String, Finding>{};
    for (final report in reports) {
      final current = {
        for (final finding in report.findings) finding.fingerprint: finding,
      };
      final introduced = [
        for (final entry in current.entries)
          if (!previous.containsKey(entry.key)) entry.value,
      ];
      final resolved = [
        for (final fingerprint in previous.keys)
          if (!current.containsKey(fingerprint)) fingerprint,
      ];
      deltas.add(
        StepDelta(report: report, introduced: introduced, resolved: resolved),
      );
      previous = current;
    }
    return FlowAnalysis(List.unmodifiable(deltas));
  }

  /// One delta per report, in flow order.
  final List<StepDelta> steps;

  /// Every finding introduced by a step *after* the first — the issues the
  /// interactions caused, excluding the initial screen's own findings.
  List<Finding> get introducedByInteractions => [
        for (var i = 1; i < steps.length; i++) ...steps[i].introduced,
      ];

  /// Whether any interaction introduced a new finding.
  bool get anyInteractionRegressed => introducedByInteractions.isNotEmpty;

  /// The JSON representation: one entry per step.
  Map<String, dynamic> toJson() => {
        'steps': [for (final delta in steps) delta.toJson()],
      };
}
