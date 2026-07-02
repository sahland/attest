import 'package:meta/meta.dart';

import 'rect_data.dart';

/// One measured text-versus-background contrast observation.
///
/// Produced by the raster collector in `attest_flutter` (see roadmap M4) and
/// consumed by the contrast rule. It carries everything the rule needs — the
/// two relative luminances plus the text's size, weight and enabled state — so
/// the rule stays pure WCAG math. A snapshot built by a pure-Dart test carries
/// none of these, and the contrast rule simply yields nothing.
@immutable
class ContrastSample {
  /// Creates a [ContrastSample].
  const ContrastSample({
    required this.label,
    required this.foregroundLuminance,
    required this.backgroundLuminance,
    required this.bounds,
    this.identifier,
    this.fontSize,
    this.isBold = false,
    this.isDisabled = false,
    this.isNonText = false,
  });

  /// The developer-assigned semantics identifier of the text node this sample
  /// was taken from, when one was set. Lets a contrast finding be anchored the
  /// same way a tree-rule finding is.
  final String? identifier;

  /// The sampled text, used for the finding message and a stable fingerprint.
  final String label;

  /// The WCAG relative luminance (0–1) of the text glyphs.
  final double foregroundLuminance;

  /// The WCAG relative luminance (0–1) of the background behind the glyphs.
  final double backgroundLuminance;

  /// The text's bounding rectangle in global logical pixels.
  final RectData bounds;

  /// The font size in logical pixels, when known.
  final double? fontSize;

  /// Whether the text is bold (weight 700 or heavier).
  final bool isBold;

  /// Whether the text belongs to a disabled control, which WCAG 1.4.3 exempts.
  final bool isDisabled;

  /// Whether this sample is a non-text graphical glyph — an icon — rather than
  /// readable text. Non-text content is governed by WCAG 1.4.11 (a flat 3:1
  /// minimum) instead of the size-dependent text minimum of 1.4.3.
  final bool isNonText;

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

  /// Whether this counts as large text under WCAG: at least 24 logical px, or at
  /// least 18.66 px when bold. Large text has a lower contrast requirement.
  bool get isLargeText {
    final size = fontSize ?? 0;
    return size >= 24 || (isBold && size >= 18.66);
  }

  /// Parses a [ContrastSample] from [json].
  factory ContrastSample.fromJson(Map<String, dynamic> json) => ContrastSample(
        label: json['label'] as String? ?? '',
        identifier: json['identifier'] as String?,
        foregroundLuminance: (json['foregroundLuminance'] as num).toDouble(),
        backgroundLuminance: (json['backgroundLuminance'] as num).toDouble(),
        bounds: json['bounds'] == null
            ? RectData.zero
            : RectData.fromJson(json['bounds'] as Map<String, dynamic>),
        fontSize: (json['fontSize'] as num?)?.toDouble(),
        isBold: json['isBold'] as bool? ?? false,
        isDisabled: json['isDisabled'] as bool? ?? false,
        isNonText: json['isNonText'] as bool? ?? false,
      );

  /// The JSON representation of this sample.
  Map<String, dynamic> toJson() => {
        if (identifier != null) 'identifier': identifier,
        if (label.isNotEmpty) 'label': label,
        'foregroundLuminance': foregroundLuminance,
        'backgroundLuminance': backgroundLuminance,
        'bounds': bounds.toJson(),
        if (fontSize != null) 'fontSize': fontSize,
        if (isBold) 'isBold': isBold,
        if (isDisabled) 'isDisabled': isDisabled,
        if (isNonText) 'isNonText': isNonText,
      };

  @override
  bool operator ==(Object other) =>
      other is ContrastSample &&
      other.identifier == identifier &&
      other.label == label &&
      other.foregroundLuminance == foregroundLuminance &&
      other.backgroundLuminance == backgroundLuminance &&
      other.bounds == bounds &&
      other.fontSize == fontSize &&
      other.isBold == isBold &&
      other.isDisabled == isDisabled &&
      other.isNonText == isNonText;

  @override
  int get hashCode => Object.hash(
        identifier,
        label,
        foregroundLuminance,
        backgroundLuminance,
        bounds,
        fontSize,
        isBold,
        isDisabled,
        isNonText,
      );

  @override
  String toString() =>
      'ContrastSample("$label", ratio: ${contrastRatio.toStringAsFixed(2)})';
}
