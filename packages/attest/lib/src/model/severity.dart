/// How serious an accessibility [Finding] is.
///
/// The values are ordered from least to most severe, so [index] can be compared
/// directly: a finding fails a gate when its severity [isAtLeast] the configured
/// gate severity.
enum Severity {
  /// Informational; never fails a gate on its own.
  info,

  /// A likely problem that should be reviewed but may be acceptable.
  warning,

  /// A definite accessibility barrier.
  error;

  /// Whether this severity is as serious as, or more serious than, [other].
  bool isAtLeast(Severity other) => index >= other.index;

  /// Parses a [Severity] from its [name].
  static Severity fromJson(String json) => Severity.values.byName(json);

  /// The JSON representation of this severity (its [name]).
  String toJson() => name;
}
