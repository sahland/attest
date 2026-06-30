import 'package:meta/meta.dart';

/// An axis-aligned rectangle in **global** logical pixels, mirrored from
/// Flutter's `Rect` so the core stays free of any Flutter dependency.
///
/// Coordinates are global (screen-relative), which is what the geometry rules
/// (target size, focus order) reason about.
@immutable
class RectData {
  /// Creates a rectangle from its [left]/[top] origin and [width]/[height].
  const RectData({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  /// Creates a rectangle from its left, top, right and bottom edges.
  const RectData.fromLTRB(double left, double top, double right, double bottom)
      : this(left: left, top: top, width: right - left, height: bottom - top);

  /// The zero-sized rectangle at the origin.
  static const RectData zero = RectData(left: 0, top: 0, width: 0, height: 0);

  /// The offset of the left edge from the origin.
  final double left;

  /// The offset of the top edge from the origin.
  final double top;

  /// The width of the rectangle.
  final double width;

  /// The height of the rectangle.
  final double height;

  /// The offset of the right edge from the origin.
  double get right => left + width;

  /// The offset of the bottom edge from the origin.
  double get bottom => top + height;

  /// The length of the shorter of the two sides.
  double get shortestSide => width < height ? width : height;

  /// Whether this rectangle has zero (or negative) area.
  bool get isEmpty => width <= 0 || height <= 0;

  /// Parses a [RectData] from [json].
  factory RectData.fromJson(Map<String, dynamic> json) => RectData(
        left: (json['left'] as num).toDouble(),
        top: (json['top'] as num).toDouble(),
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
      );

  /// The JSON representation of this rectangle.
  Map<String, dynamic> toJson() => {
        'left': left,
        'top': top,
        'width': width,
        'height': height,
      };

  @override
  bool operator ==(Object other) =>
      other is RectData &&
      other.left == left &&
      other.top == top &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(left, top, width, height);

  @override
  String toString() =>
      'RectData(${left.toStringAsFixed(1)}, ${top.toStringAsFixed(1)}, '
      '${width.toStringAsFixed(1)} x ${height.toStringAsFixed(1)})';
}
