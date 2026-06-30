import 'package:meta/meta.dart';

/// One measured text-versus-background contrast observation for a node.
///
/// Produced by the raster collector in `attest_flutter` (see roadmap M4) and
/// consumed by the contrast rule. A snapshot built by a pure-Dart test carries
/// none of these, and the contrast rule simply yields nothing — graceful
/// degradation rather than a crash.
@immutable
class ContrastSample {
  /// Creates a [ContrastSample] relating a node to its measured luminances.
  const ContrastSample({
    required this.nodeId,
    required this.foregroundLuminance,
    required this.backgroundLuminance,
  });

  /// The [SemanticsNodeData.id] of the text node this sample describes.
  final int nodeId;

  /// The WCAG relative luminance (0–1) of the text glyphs.
  final double foregroundLuminance;

  /// The WCAG relative luminance (0–1) of the background behind the glyphs.
  final double backgroundLuminance;

  /// The WCAG contrast ratio between foreground and background, in the range
  /// 1.0 (no contrast) to 21.0 (black on white).
  double get contrastRatio {
    final hi = foregroundLuminance > backgroundLuminance
        ? foregroundLuminance
        : backgroundLuminance;
    final lo = foregroundLuminance > backgroundLuminance
        ? backgroundLuminance
        : foregroundLuminance;
    return (hi + 0.05) / (lo + 0.05);
  }

  /// Parses a [ContrastSample] from [json].
  factory ContrastSample.fromJson(Map<String, dynamic> json) => ContrastSample(
        nodeId: json['nodeId'] as int,
        foregroundLuminance: (json['foregroundLuminance'] as num).toDouble(),
        backgroundLuminance: (json['backgroundLuminance'] as num).toDouble(),
      );

  /// The JSON representation of this sample.
  Map<String, dynamic> toJson() => {
        'nodeId': nodeId,
        'foregroundLuminance': foregroundLuminance,
        'backgroundLuminance': backgroundLuminance,
      };

  @override
  bool operator ==(Object other) =>
      other is ContrastSample &&
      other.nodeId == nodeId &&
      other.foregroundLuminance == foregroundLuminance &&
      other.backgroundLuminance == backgroundLuminance;

  @override
  int get hashCode =>
      Object.hash(nodeId, foregroundLuminance, backgroundLuminance);

  @override
  String toString() => 'ContrastSample(nodeId: $nodeId, ratio: '
      '${contrastRatio.toStringAsFixed(2)})';
}
