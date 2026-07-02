import 'package:meta/meta.dart';

import '../model/criterion.dart';

/// How much of a success criterion attest can verify automatically.
///
/// The honest split at the heart of the coverage matrix: most criteria need
/// human judgement, and the tool says so rather than implying full coverage.
enum CoverageStatus {
  /// A rule checks the machine-checkable substance of this criterion.
  automated,

  /// A rule checks part of this criterion; the rest needs human review.
  partial,

  /// Out of automated scope — it requires human judgement (meaning of colour,
  /// usefulness of alt text, media captions, and the like).
  manual;

  /// Parses a [CoverageStatus] from its [name].
  static CoverageStatus fromJson(String json) =>
      CoverageStatus.values.byName(json);

  /// The JSON representation of this status (its [name]).
  String toJson() => name;
}

/// One row of the coverage matrix: a success criterion, how far attest covers
/// it, the rule(s) that do so, and a short human-facing note.
@immutable
class CriterionCoverage {
  /// Creates a [CriterionCoverage].
  const CriterionCoverage({
    required this.criterion,
    required this.status,
    this.ruleIds = const [],
    required this.guidance,
  });

  /// The success criterion this row describes.
  final Criterion criterion;

  /// How far attest covers it.
  final CoverageStatus status;

  /// The ids of the rules that cover it; empty when [status] is
  /// [CoverageStatus.manual].
  final List<String> ruleIds;

  /// A concise, own-words note: what a rule checks here, or — for partial and
  /// manual criteria — what a human still needs to verify. Never the W3C's
  /// copyrighted normative wording.
  final String guidance;

  /// Whether this criterion is at least partly automated.
  bool get isAutomated => status != CoverageStatus.manual;

  /// The JSON representation of this row.
  Map<String, dynamic> toJson() => {
        'criterion': criterion.toJson(),
        'status': status.toJson(),
        if (ruleIds.isNotEmpty) 'ruleIds': ruleIds,
        'guidance': guidance,
      };

  @override
  String toString() =>
      'CriterionCoverage(${criterion.wcag}, ${status.name}, $ruleIds)';
}
