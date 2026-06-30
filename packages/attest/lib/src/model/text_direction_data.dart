/// The reading direction of a piece of text or a layout, mirrored from Flutter's
/// `TextDirection` so the core stays free of any Flutter dependency.
enum TextDirectionData {
  /// Left-to-right, as in English.
  ltr,

  /// Right-to-left, as in Arabic or Hebrew.
  rtl;

  /// Parses a [TextDirectionData] from its [name].
  static TextDirectionData fromJson(String json) =>
      TextDirectionData.values.byName(json);

  /// The JSON representation of this direction (its [name]).
  String toJson() => name;
}
