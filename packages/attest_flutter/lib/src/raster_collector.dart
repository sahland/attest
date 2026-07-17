import 'dart:math' as math;
import 'dart:typed_data';

import 'package:attest/attest.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

/// Rasterizes the screen and measures the contrast of each piece of text against
/// the background actually painted behind it.
///
/// This is what a static analyzer cannot do: it works on rendered pixels. Each
/// text render object contributes its known foreground colour and font metrics,
/// while the background is sampled from the rasterized image (the dominant
/// non-text colour within the text's box). Sampling over gradients and images is
/// inherently noisy, which is why the contrast rule downgrades borderline ratios.
///
/// **Experimental:** most tests only need `tester.auditAccessibility()`, which
/// drives this internally. The collector's own signature may still evolve, so
/// it is exempt from the 1.0 stability promise.
@experimental
class RasterCollector {
  /// Creates a [RasterCollector].
  const RasterCollector();

  /// Colour distance (summed channel difference, 0–765) above which a sampled
  /// pixel is treated as background rather than glyph.
  static const int _backgroundDistance = 60;

  /// The most pixels [_sampleBackground] reads from a single text box. The
  /// background colour is taken as the mode within the box, which is invariant
  /// under uniform subsampling of a solid field, so on a larger box the scan
  /// steps over pixels rather than reading every one — bounding the per-box
  /// cost regardless of the box's size. A thousand samples is far more than a
  /// mode needs to be stable.
  static const int _maxSamplesPerBox = 1024;

  /// Below this foreground opacity the text is assumed to belong to a disabled
  /// control (Material disabled text is ~0.38 opaque).
  static const double _disabledOpacity = 0.6;

  /// Samples every text node in the currently pumped screen.
  Future<List<ContrastSample>> collect(WidgetTester tester) async {
    final samples = <ContrastSample>[];

    for (final view in tester.binding.renderViews) {
      final paragraphs = <RenderParagraph>[];
      _collectParagraphs(view, paragraphs);
      if (paragraphs.isEmpty) continue;

      final devicePixelRatio = view.flutterView.devicePixelRatio;
      final byteData = await tester.runAsync(() async {
        final image = await (view.debugLayer! as OffsetLayer).toImage(
          view.paintBounds,
          pixelRatio: 1 / devicePixelRatio,
        );
        final data = await image.toByteData();
        image.dispose();
        return data;
      });
      if (byteData == null) continue;

      final image = _SampledImage(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
        (view.paintBounds.width / devicePixelRatio).round(),
        (view.paintBounds.height / devicePixelRatio).round(),
      );

      for (final paragraph in paragraphs) {
        final sample = _sample(paragraph, image);
        if (sample != null) samples.add(sample);
      }
    }

    return samples;
  }

  void _collectParagraphs(RenderObject node, List<RenderParagraph> out) {
    if (node is RenderParagraph) out.add(node);
    node.visitChildren((child) => _collectParagraphs(child, out));
  }

  ContrastSample? _sample(RenderParagraph paragraph, _SampledImage image) {
    final text = paragraph.text.toPlainText().trim();
    if (text.isEmpty) return null;

    final style = paragraph.text.style;
    final color = style?.color;
    if (color == null) return null;

    final origin = paragraph.localToGlobal(Offset.zero);
    final rect = origin & paragraph.size;

    final foreground = _Rgb(
      (color.r * 255).round(),
      (color.g * 255).round(),
      (color.b * 255).round(),
    );

    final background = _sampleBackground(rect, image, foreground);
    if (background == null) return null;

    // Blend the foreground over the sampled background when it is translucent,
    // so the luminance reflects what is actually seen.
    final opacity = color.a;
    final blended = opacity >= 1
        ? foreground
        : _Rgb(
            _mix(foreground.r, background.r, opacity),
            _mix(foreground.g, background.g, opacity),
            _mix(foreground.b, background.b, opacity),
          );

    return ContrastSample(
      label: text,
      identifier: _identifierOf(paragraph),
      isNonText: _isIconGlyph(text),
      foregroundLuminance: _luminance(blended),
      backgroundLuminance: _luminance(background),
      bounds: RectData(
        left: rect.left,
        top: rect.top,
        width: rect.width,
        height: rect.height,
      ),
      fontSize: style?.fontSize,
      isBold:
          (style?.fontWeight ?? FontWeight.normal).value >=
          FontWeight.bold.value,
      isDisabled: opacity < _disabledOpacity,
    );
  }

  /// The developer-assigned semantics identifier nearest to [paragraph]: its
  /// own semantics node's, or the first one found walking up the render tree
  /// (text semantics are commonly merged into an ancestor). Best-effort debug
  /// data; `null` when nothing in the chain carries one.
  String? _identifierOf(RenderParagraph paragraph) {
    RenderObject? node = paragraph;
    for (var hops = 0; node != null && hops < 64; hops++) {
      final identifier = node.debugSemantics?.getSemanticsData().identifier;
      if (identifier != null && identifier.isNotEmpty) return identifier;
      node = node.parent;
    }
    return null;
  }

  /// Whether [text] is an icon glyph rather than readable text.
  ///
  /// Icon fonts (Material Icons, Cupertino Icons, and custom sets) map each icon
  /// to a Unicode Private Use Area code point. Text never uses those, so a
  /// string made entirely of PUA runes is an icon, governed by WCAG 1.4.11.
  static bool _isIconGlyph(String text) {
    final runes = text.runes.where((r) => r > 0x20).toList();
    if (runes.isEmpty) return false;
    return runes.every(_isPrivateUse);
  }

  static bool _isPrivateUse(int rune) =>
      (rune >= 0xE000 && rune <= 0xF8FF) ||
      (rune >= 0xF0000 && rune <= 0xFFFFD) ||
      (rune >= 0x100000 && rune <= 0x10FFFD);

  /// The background is the most frequent colour within the text's box, ignoring
  /// pixels close to the foreground (the glyphs and their antialiased edges).
  /// A mode is far more robust than an average for a solid background, which a
  /// thin glyph never outnumbers.
  ///
  /// The loop reads packed RGB integers straight from the pixel buffer — no
  /// per-pixel object is allocated — and steps by [_strideFor] so a large box
  /// costs no more than a small one.
  _Rgb? _sampleBackground(Rect rect, _SampledImage image, _Rgb foreground) {
    final left = rect.left.floor();
    final top = rect.top.floor();
    final right = rect.right.ceil();
    final bottom = rect.bottom.ceil();
    if (right <= left || bottom <= top) return null;

    final step = _strideFor((right - left) * (bottom - top));
    final fr = foreground.r;
    final fg = foreground.g;
    final fb = foreground.b;
    final counts = <int, int>{};

    for (var y = top; y < bottom; y += step) {
      for (var x = left; x < right; x += step) {
        final packed = image.packedAt(x, y);
        if (packed < 0) continue;
        final r = (packed >> 16) & 0xff;
        final g = (packed >> 8) & 0xff;
        final b = packed & 0xff;
        if ((r - fr).abs() + (g - fg).abs() + (b - fb).abs() <=
            _backgroundDistance) {
          continue;
        }
        counts[packed] = (counts[packed] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return null;

    var bestKey = 0;
    var bestCount = -1;
    counts.forEach((key, count) {
      if (count > bestCount) {
        bestCount = count;
        bestKey = key;
      }
    });

    return _Rgb((bestKey >> 16) & 0xff, (bestKey >> 8) & 0xff, bestKey & 0xff);
  }

  /// The sampling step for a box of [area] pixels: 1 up to [_maxSamplesPerBox],
  /// then the smallest stride that keeps the sampled count near that cap.
  static int _strideFor(int area) => area <= _maxSamplesPerBox
      ? 1
      : math.max(1, math.sqrt(area / _maxSamplesPerBox).floor());

  int _mix(int foreground, int background, double opacity) =>
      (foreground * opacity + background * (1 - opacity)).round();

  double _luminance(_Rgb color) =>
      0.2126 * _channel(color.r) +
      0.7152 * _channel(color.g) +
      0.0722 * _channel(color.b);

  double _channel(int value) {
    final s = value / 255.0;
    return s <= 0.03928
        ? s / 12.92
        : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }
}

/// A read-only view over rasterized RGBA pixel data.
class _SampledImage {
  _SampledImage(this._data, this.width, this.height);

  final Uint8List _data;
  final int width;
  final int height;

  /// The RGB of pixel ([x], [y]) packed as `(r << 16) | (g << 8) | b`, or `-1`
  /// when the coordinate is outside the image. Packing avoids allocating an
  /// object for each of the many pixels the background scan reads.
  int packedAt(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return -1;
    final offset = (y * width + x) * 4;
    if (offset + 2 >= _data.length) return -1;
    return (_data[offset] << 16) | (_data[offset + 1] << 8) | _data[offset + 2];
  }
}

class _Rgb {
  const _Rgb(this.r, this.g, this.b);

  final int r;
  final int g;
  final int b;
}
