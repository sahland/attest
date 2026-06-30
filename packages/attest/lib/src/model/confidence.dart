/// How much trust to place in a [Finding].
///
/// Deterministic findings come from structural or mathematical facts and are
/// safe to gate on. Heuristic findings are best-effort guesses that ship with
/// easy suppression and a visible tag, because they can produce false positives.
enum Confidence {
  /// Derived from structure or math; not expected to produce false positives.
  deterministic,

  /// A best-effort heuristic that may produce false positives.
  heuristic;

  /// Parses a [Confidence] from its [name].
  static Confidence fromJson(String json) => Confidence.values.byName(json);

  /// The JSON representation of this confidence (its [name]).
  String toJson() => name;
}
