import 'package:meta/meta.dart';

import '../model/finding.dart';

/// A set of accepted finding fingerprints — the record of what a project has
/// already reviewed, against which new runs are diffed.
///
/// Fingerprints are the unit of comparison so an accepted finding stays accepted
/// across runs even as the layout shifts (see `Fingerprinter`).
@immutable
class Baseline {
  /// Creates a [Baseline] from an explicit set of [fingerprints].
  const Baseline(this.fingerprints);

  /// Creates a [Baseline] capturing the fingerprints of [findings].
  factory Baseline.fromFindings(Iterable<Finding> findings) =>
      Baseline({for (final finding in findings) finding.fingerprint});

  /// An empty baseline; every finding counts as new against it.
  static const Baseline empty = Baseline(<String>{});

  /// The accepted fingerprints.
  final Set<String> fingerprints;

  /// Whether [fingerprint] has been accepted.
  bool contains(String fingerprint) => fingerprints.contains(fingerprint);

  /// Parses a [Baseline] from [json].
  factory Baseline.fromJson(Map<String, dynamic> json) => Baseline({
        for (final fingerprint
            in (json['fingerprints'] as List<dynamic>? ?? const []))
          fingerprint as String,
      });

  /// The JSON representation of this baseline, with fingerprints sorted so the
  /// file is stable under version control.
  Map<String, dynamic> toJson() => {
        'version': 1,
        'fingerprints': fingerprints.toList()..sort(),
      };

  @override
  bool operator ==(Object other) =>
      other is Baseline &&
      other.fingerprints.length == fingerprints.length &&
      other.fingerprints.containsAll(fingerprints);

  @override
  int get hashCode => Object.hashAllUnordered(fingerprints);

  @override
  String toString() => 'Baseline(${fingerprints.length} fingerprints)';
}
