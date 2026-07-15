import 'package:meta/meta.dart';

import 'confidence.dart';
import 'criterion.dart';
import 'rect_data.dart';
import 'severity.dart';
import 'source_location.dart';

/// A single accessibility violation reported by a rule.
///
/// A finding is self-describing: it names the rule, cites the standard
/// [criterion], records where in the source and on screen the problem is, and
/// carries a [fingerprint] that is stable across runs so the baseline gate can
/// tell a genuine regression from a layout shift.
@immutable
class Finding {
  /// Creates a [Finding].
  const Finding({
    required this.ruleId,
    required this.criterion,
    required this.severity,
    required this.confidence,
    required this.message,
    required this.suggestion,
    required this.fingerprint,
    this.codeExample,
    this.identifier,
    this.location,
    this.bounds = RectData.zero,
  });

  /// The id of the rule that produced this finding, e.g. `attest/interactive-name`.
  final String ruleId;

  /// The standard clause this finding is bound to.
  final Criterion criterion;

  /// How serious this finding is.
  final Severity severity;

  /// How much to trust this finding.
  final Confidence confidence;

  /// A human-readable description of the problem.
  final String message;

  /// A concrete suggestion for fixing the problem, ideally with example code.
  final String suggestion;

  /// A ready-to-paste Dart snippet showing the fix, typically a `// Before` /
  /// `// After` pair, when the rule has a canonical code-level remedy.
  ///
  /// Present for deterministic rules whose fix is a specific widget change
  /// (adding an accessible name, exposing a value); null for geometric or
  /// visual findings (contrast, target size) whose fix is not a code template.
  /// It is guidance to copy and adapt, not an edit attest applies for you.
  final String? codeExample;

  /// A hash that is stable across runs but changes on a genuine regression; the
  /// unit of the baseline diff. See `Fingerprinter`.
  final String fingerprint;

  /// The developer-assigned semantics identifier of the offending node, or of
  /// its nearest ancestor that has one, when available.
  ///
  /// Set from `SemanticsProperties.identifier`. It is more stable and meaningful
  /// than a source location for pointing at the element at fault, and it is what
  /// the validation corpus matches an expected finding against.
  final String? identifier;

  /// Where the originating widget was created, when available.
  final SourceLocation? location;

  /// The offending element's bounding rectangle in global logical pixels.
  final RectData bounds;

  /// Parses a [Finding] from [json].
  factory Finding.fromJson(Map<String, dynamic> json) => Finding(
        ruleId: json['ruleId'] as String,
        criterion:
            Criterion.fromJson(json['criterion'] as Map<String, dynamic>),
        severity: Severity.fromJson(json['severity'] as String),
        confidence: Confidence.fromJson(json['confidence'] as String),
        message: json['message'] as String,
        suggestion: json['suggestion'] as String,
        fingerprint: json['fingerprint'] as String,
        codeExample: json['codeExample'] as String?,
        identifier: json['identifier'] as String?,
        location: json['location'] == null
            ? null
            : SourceLocation.fromJson(json['location'] as Map<String, dynamic>),
        bounds: json['bounds'] == null
            ? RectData.zero
            : RectData.fromJson(json['bounds'] as Map<String, dynamic>),
      );

  /// The JSON representation of this finding.
  Map<String, dynamic> toJson() => {
        'ruleId': ruleId,
        'criterion': criterion.toJson(),
        'severity': severity.toJson(),
        'confidence': confidence.toJson(),
        'message': message,
        'suggestion': suggestion,
        'fingerprint': fingerprint,
        if (codeExample != null) 'codeExample': codeExample,
        if (identifier != null) 'identifier': identifier,
        if (location != null) 'location': location!.toJson(),
        'bounds': bounds.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      other is Finding &&
      other.ruleId == ruleId &&
      other.criterion == criterion &&
      other.severity == severity &&
      other.confidence == confidence &&
      other.message == message &&
      other.suggestion == suggestion &&
      other.fingerprint == fingerprint &&
      other.codeExample == codeExample &&
      other.identifier == identifier &&
      other.location == location &&
      other.bounds == bounds;

  @override
  int get hashCode => Object.hash(
        ruleId,
        criterion,
        severity,
        confidence,
        message,
        suggestion,
        fingerprint,
        codeExample,
        identifier,
        location,
        bounds,
      );

  @override
  String toString() => 'Finding($ruleId, ${severity.name}, "$message")';
}
