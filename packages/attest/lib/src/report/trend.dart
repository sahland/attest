import 'package:meta/meta.dart';

import '../model/finding.dart';
import '../model/severity.dart';
import 'baseline_gate.dart';

/// A compact summary of one audit run: when it happened, how many findings it
/// produced, and the gate outcome. Small and serializable, it is the unit a
/// [TrendLog] accumulates so a project can see its accessibility debt move over
/// time rather than only pass/fail a single run.
@immutable
class RunSummary {
  /// Creates a [RunSummary].
  const RunSummary({
    required this.timestamp,
    required this.total,
    required this.bySeverity,
    this.newCount = 0,
    this.resolvedCount = 0,
  });

  /// Summarizes [findings] taken at [timestamp], optionally recording how many
  /// were [newCount] (regressions) and how many baseline findings were
  /// [resolvedCount] this run.
  factory RunSummary.of(
    Iterable<Finding> findings, {
    required DateTime timestamp,
    int newCount = 0,
    int resolvedCount = 0,
  }) {
    final bySeverity = <Severity, int>{};
    var total = 0;
    for (final finding in findings) {
      total++;
      bySeverity[finding.severity] = (bySeverity[finding.severity] ?? 0) + 1;
    }
    return RunSummary(
      timestamp: timestamp,
      total: total,
      bySeverity: Map.unmodifiable(bySeverity),
      newCount: newCount,
      resolvedCount: resolvedCount,
    );
  }

  /// When the run was taken.
  final DateTime timestamp;

  /// The total number of findings in the run.
  final int total;

  /// The finding count for each severity present in the run.
  final Map<Severity, int> bySeverity;

  /// How many findings were new (not in the baseline) — the regressions.
  final int newCount;

  /// How many baseline findings the run no longer produced — the fixes.
  final int resolvedCount;

  /// The finding count for [severity] (zero when the run had none).
  int count(Severity severity) => bySeverity[severity] ?? 0;

  /// The JSON representation of this summary.
  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toUtc().toIso8601String(),
        'total': total,
        'bySeverity': {
          for (final entry in bySeverity.entries)
            entry.key.toJson(): entry.value,
        },
        'newCount': newCount,
        'resolvedCount': resolvedCount,
      };

  /// Parses a [RunSummary] from [json].
  factory RunSummary.fromJson(Map<String, dynamic> json) => RunSummary(
        timestamp: DateTime.parse(json['timestamp'] as String),
        total: json['total'] as int,
        bySeverity: {
          for (final entry
              in (json['bySeverity'] as Map<String, dynamic>? ?? const {})
                  .entries)
            Severity.fromJson(entry.key): entry.value as int,
        },
        newCount: json['newCount'] as int? ?? 0,
        resolvedCount: json['resolvedCount'] as int? ?? 0,
      );
}

/// The change between one run and the one before it — the "since last run"
/// story a report shows so a developer sees whether the screen is getting more
/// or less accessible, not just its current count.
@immutable
class RunDelta {
  /// Creates a [RunDelta] comparing [current] against [previous] (null when
  /// this is the first recorded run).
  const RunDelta({required this.current, required this.previous});

  /// The run being reported.
  final RunSummary current;

  /// The run immediately before it, or null if there is no earlier run.
  final RunSummary? previous;

  /// Whether there is an earlier run to compare against.
  bool get hasPrevious => previous != null;

  /// The change in total findings since the previous run (negative is better).
  /// Equals the current total when there is no earlier run.
  int get totalDelta => current.total - (previous?.total ?? 0);

  /// The change in the count of [severity] since the previous run.
  int severityDelta(Severity severity) =>
      current.count(severity) - (previous?.count(severity) ?? 0);

  /// Whether the total dropped since the previous run.
  bool get improved => hasPrevious && totalDelta < 0;

  /// Whether the total rose since the previous run.
  bool get regressed => hasPrevious && totalDelta > 0;
}

/// An ordered history of [RunSummary]s (oldest first), persisted between runs so
/// a report can show a trend. It is append-only and length-capped: appending
/// returns a new log rather than mutating in place.
@immutable
class TrendLog {
  /// Creates a [TrendLog] from an ordered (oldest-first) list of [runs].
  const TrendLog(this.runs);

  /// An empty history.
  static const TrendLog empty = TrendLog(<RunSummary>[]);

  /// The default number of most-recent runs kept when appending.
  static const int defaultKeep = 50;

  /// The runs, oldest first.
  final List<RunSummary> runs;

  /// A new log with [summary] appended, keeping at most [keepLast] most-recent
  /// runs so the history file cannot grow without bound.
  TrendLog append(RunSummary summary, {int keepLast = defaultKeep}) {
    final next = [...runs, summary];
    final start = next.length > keepLast ? next.length - keepLast : 0;
    return TrendLog(List.unmodifiable(next.sublist(start)));
  }

  /// The change from the previous run to the most recent one, or null when the
  /// log is empty.
  RunDelta? get latestDelta {
    if (runs.isEmpty) return null;
    return RunDelta(
      current: runs.last,
      previous: runs.length >= 2 ? runs[runs.length - 2] : null,
    );
  }

  /// The JSON representation of this log.
  Map<String, dynamic> toJson() => {
        'version': 1,
        'runs': [for (final run in runs) run.toJson()],
      };

  /// Parses a [TrendLog] from [json].
  factory TrendLog.fromJson(Map<String, dynamic> json) => TrendLog([
        for (final run in (json['runs'] as List<dynamic>? ?? const []))
          RunSummary.fromJson(run as Map<String, dynamic>),
      ]);
}

/// Builds the [RunSummary] for a gate result taken at [timestamp].
///
/// A convenience for the common case: the run's findings are the known plus new
/// findings the gate partitioned, its regressions are the new ones, and its
/// fixes are the resolved baseline fingerprints.
RunSummary summarizeRun(GateResult gate, {required DateTime timestamp}) =>
    RunSummary.of(
      [...gate.knownFindings, ...gate.newFindings],
      timestamp: timestamp,
      newCount: gate.newFindings.length,
      resolvedCount: gate.resolvedFingerprints.length,
    );
