/// How the target-size rule chooses its minimum acceptable touch-target size.
enum TargetSizeMode {
  /// Platform guidance: 48 logical pixels (Material) by default, configurable to
  /// 44 (iOS) via `RuleConfig.platformTargetSize`. The recommended default.
  platform,

  /// The strict WCAG 2.5.8 minimum of 24 logical pixels.
  wcagMinimum;

  /// Parses a [TargetSizeMode] from its [name].
  static TargetSizeMode fromJson(String json) =>
      TargetSizeMode.values.byName(json);

  /// The JSON representation of this mode (its [name]).
  String toJson() => name;
}
