import 'package:meta/meta.dart';

/// The standard clause a [Finding] is bound to.
///
/// Every rule cites a criterion: a WCAG success criterion (number and level)
/// together with the corresponding EN 301 549 clause. A finding with no citable
/// criterion is not allowed — that is the single most visible thing separating a
/// compliance instrument from a linter.
@immutable
class Criterion {
  /// Creates a [Criterion].
  const Criterion({
    required this.wcag,
    required this.wcagLevel,
    required this.en301549,
    required this.title,
    this.understanding,
  });

  /// The WCAG success-criterion number, e.g. `1.4.3`.
  final String wcag;

  /// The WCAG conformance level, `A` or `AA`.
  final String wcagLevel;

  /// The corresponding EN 301 549 clause, e.g. `11.5.2.4`.
  final String en301549;

  /// The human-readable title of the criterion, e.g. `Contrast (Minimum)`.
  final String title;

  /// The canonical W3C "Understanding" page for this criterion, when known —
  /// the authoritative explanation of what it requires and how to satisfy it.
  ///
  /// Surfaced to developers as the "learn more" link on a finding (the SARIF
  /// `helpUri`, the test-failure output). Null for a criterion parsed from
  /// older JSON that predates this field.
  final String? understanding;

  /// Parses a [Criterion] from [json].
  factory Criterion.fromJson(Map<String, dynamic> json) => Criterion(
        wcag: json['wcag'] as String,
        wcagLevel: json['wcagLevel'] as String,
        en301549: json['en301549'] as String,
        title: json['title'] as String,
        understanding: json['understanding'] as String?,
      );

  /// The JSON representation of this criterion.
  Map<String, dynamic> toJson() => {
        'wcag': wcag,
        'wcagLevel': wcagLevel,
        'en301549': en301549,
        'title': title,
        if (understanding != null) 'understanding': understanding,
      };

  @override
  bool operator ==(Object other) =>
      other is Criterion &&
      other.wcag == wcag &&
      other.wcagLevel == wcagLevel &&
      other.en301549 == en301549 &&
      other.title == title &&
      other.understanding == understanding;

  @override
  int get hashCode =>
      Object.hash(wcag, wcagLevel, en301549, title, understanding);

  @override
  String toString() =>
      'WCAG $wcag ($wcagLevel) / EN 301 549 §$en301549 — $title';
}
