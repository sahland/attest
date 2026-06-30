import 'package:meta/meta.dart';

/// The result of re-pumping a screen under an enlarged text scale.
///
/// Produced by the text-scale collector in `attest_flutter` (see roadmap M3) and
/// consumed by the text-overflow rule. A snapshot built by a pure-Dart test
/// carries none of these, and the overflow rule simply yields nothing.
@immutable
class TextScaleObservation {
  /// Creates a [TextScaleObservation] for a single re-pump.
  const TextScaleObservation({
    required this.textScale,
    required this.overflowed,
    this.nodeId,
    this.details = '',
  });

  /// The linear text scale factor applied for this observation (e.g. 1.3, 2.0).
  final double textScale;

  /// Whether layout overflow or text clipping was detected at this scale.
  final bool overflowed;

  /// The [SemanticsNodeData.id] implicated, when it could be determined.
  final int? nodeId;

  /// The captured overflow message, when one was reported.
  final String details;

  /// Parses a [TextScaleObservation] from [json].
  factory TextScaleObservation.fromJson(Map<String, dynamic> json) =>
      TextScaleObservation(
        textScale: (json['textScale'] as num).toDouble(),
        overflowed: json['overflowed'] as bool,
        nodeId: json['nodeId'] as int?,
        details: json['details'] as String? ?? '',
      );

  /// The JSON representation of this observation.
  Map<String, dynamic> toJson() => {
        'textScale': textScale,
        'overflowed': overflowed,
        if (nodeId != null) 'nodeId': nodeId,
        if (details.isNotEmpty) 'details': details,
      };

  @override
  bool operator ==(Object other) =>
      other is TextScaleObservation &&
      other.textScale == textScale &&
      other.overflowed == overflowed &&
      other.nodeId == nodeId &&
      other.details == details;

  @override
  int get hashCode => Object.hash(textScale, overflowed, nodeId, details);

  @override
  String toString() =>
      'TextScaleObservation(textScale: $textScale, overflowed: $overflowed)';
}
