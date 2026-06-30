import 'package:meta/meta.dart';

/// The subset of a text node's visual style the rules need, mirrored from
/// Flutter's `TextStyle` so the core stays free of any Flutter dependency.
///
/// Populated only for nodes that paint text; `null` otherwise.
@immutable
class TextStyleData {
  /// Creates a [TextStyleData].
  const TextStyleData({this.fontSize, this.fontWeight});

  /// The font size in logical pixels, when known.
  final double? fontSize;

  /// The font weight on the usual 100–900 scale (400 = normal, 700 = bold),
  /// when known.
  final int? fontWeight;

  /// Whether the text is bold, i.e. a weight of 700 or heavier.
  bool get isBold => (fontWeight ?? 400) >= 700;

  /// Parses a [TextStyleData] from [json].
  factory TextStyleData.fromJson(Map<String, dynamic> json) => TextStyleData(
        fontSize: (json['fontSize'] as num?)?.toDouble(),
        fontWeight: json['fontWeight'] as int?,
      );

  /// The JSON representation of this style.
  Map<String, dynamic> toJson() => {
        if (fontSize != null) 'fontSize': fontSize,
        if (fontWeight != null) 'fontWeight': fontWeight,
      };

  @override
  bool operator ==(Object other) =>
      other is TextStyleData &&
      other.fontSize == fontSize &&
      other.fontWeight == fontWeight;

  @override
  int get hashCode => Object.hash(fontSize, fontWeight);

  @override
  String toString() => 'TextStyleData(fontSize: $fontSize, '
      'fontWeight: $fontWeight)';
}
