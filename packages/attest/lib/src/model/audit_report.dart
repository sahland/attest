import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'audit_meta.dart';
import 'finding.dart';
import 'severity.dart';

const DeepCollectionEquality _deepEquality = DeepCollectionEquality();

/// The result of auditing one screen: the [findings] plus the [meta] describing
/// the run.
///
/// The report knows the [gateSeverity] it should be judged against, so [passes]
/// is a property of the report rather than something the caller has to recompute.
@immutable
class AuditReport {
  /// Creates an [AuditReport].
  const AuditReport({
    required this.findings,
    required this.meta,
    this.gateSeverity = Severity.error,
    this.transcript = const [],
  });

  /// Every finding produced for the screen, regardless of severity.
  final List<Finding> findings;

  /// Context about how the report was produced.
  final AuditMeta meta;

  /// Findings at or above this severity fail the gate.
  final Severity gateSeverity;

  /// The screen-reader transcript: the announcements a screen reader would make,
  /// in traversal order. Empty unless the audit was asked to produce it.
  ///
  /// The field is stable; the exact wording of each line is not — it may be
  /// refined until the transcript is cross-validated against real
  /// VoiceOver/TalkBack captures (see `TranscriptGenerator`).
  final List<String> transcript;

  /// Returns a copy with [transcript] replaced.
  AuditReport copyWith({List<String>? transcript}) => AuditReport(
        findings: findings,
        meta: meta,
        gateSeverity: gateSeverity,
        transcript: transcript ?? this.transcript,
      );

  /// The findings that fail the gate, i.e. those at or above [gateSeverity].
  Iterable<Finding> get gateFailures =>
      findings.where((f) => f.severity.isAtLeast(gateSeverity));

  /// Whether the screen passes: no finding is at or above [gateSeverity].
  bool get passes => gateFailures.isEmpty;

  /// The number of findings at each severity, useful for summaries.
  Map<Severity, int> get countsBySeverity {
    final counts = <Severity, int>{};
    for (final f in findings) {
      counts[f.severity] = (counts[f.severity] ?? 0) + 1;
    }
    return counts;
  }

  /// Parses an [AuditReport] from [json].
  factory AuditReport.fromJson(Map<String, dynamic> json) => AuditReport(
        findings: [
          for (final f in (json['findings'] as List<dynamic>? ?? const []))
            Finding.fromJson(f as Map<String, dynamic>),
        ],
        meta: AuditMeta.fromJson(json['meta'] as Map<String, dynamic>),
        gateSeverity: json['gateSeverity'] == null
            ? Severity.error
            : Severity.fromJson(json['gateSeverity'] as String),
        transcript: [
          for (final line in (json['transcript'] as List<dynamic>? ?? const []))
            line as String,
        ],
      );

  /// The JSON representation of this report.
  Map<String, dynamic> toJson() => {
        'findings': [for (final f in findings) f.toJson()],
        'meta': meta.toJson(),
        'gateSeverity': gateSeverity.toJson(),
        if (transcript.isNotEmpty) 'transcript': transcript,
      };

  @override
  bool operator ==(Object other) =>
      other is AuditReport &&
      _deepEquality.equals(other.findings, findings) &&
      other.meta == meta &&
      other.gateSeverity == gateSeverity &&
      _deepEquality.equals(other.transcript, transcript);

  @override
  int get hashCode => Object.hash(
        _deepEquality.hash(findings),
        meta,
        gateSeverity,
        _deepEquality.hash(transcript),
      );

  @override
  String toString() =>
      'AuditReport(${findings.length} findings, passes: $passes)';
}
