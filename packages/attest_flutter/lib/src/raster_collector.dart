import 'dart:math' as math;
import 'dart:typed_data';

import 'package:attest/attest.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rasterizes the screen and measures the contrast of each piece of text against
/// the background actually painted behind it.
///
/// This is what a static analyzer cannot do: it works on rendered pixels. Each
/// text render object contributes its known foreground colour and font metrics,
/// while the background is sampled from the rasterized image (the dominant
/// non-text colour within the text's box). Sampling over gradients and images is
/// inherently noisy, which is why the contrast rule downgrades borderline ratios.
class RasterCollector {
  /// Creates a [RasterCollector].
  const RasterCollector();

  /// Colour distance (summed channel difference, 0–765) above which a sampled
  /// pixel is treated as background rather than glyph.
  static const int _backgroundDistance = 60;

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
        byteData,
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

  /// The background is the most frequent colour within the text's box, ignoring
  /// pixels close to the foreground (the glyphs and their antialiased edges).
  /// A mode is far more robust than an average for a solid background, which a
  /// thin glyph never outnumbers.
  _Rgb? _sampleBackground(Rect rect, _SampledImage image, _Rgb foreground) {
    final counts = <int, int>{};

    final left = rect.left.floor();
    final top = rect.top.floor();
    final right = rect.right.ceil();
    final bottom = rect.bottom.ceil();

    for (var y = top; y < bottom; y++) {
      for (var x = left; x < right; x++) {
        final pixel = image.colorAt(x, y);
        if (pixel == null) continue;
        if (_distance(pixel, foreground) <= _backgroundDistance) continue;
        final key = (pixel.r << 16) | (pixel.g << 8) | pixel.b;
        counts[key] = (counts[key] ?? 0) + 1;
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

  int _mix(int foreground, int background, double opacity) =>
      (foreground * opacity + background * (1 - opacity)).round();

  int _distance(_Rgb a, _Rgb b) =>
      (a.r - b.r).abs() + (a.g - b.g).abs() + (a.b - b.b).abs();

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

  final ByteData _data;
  final int width;
  final int height;

  _Rgb? colorAt(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return null;
    final offset = (y * width + x) * 4;
    if (offset + 3 >= _data.lengthInBytes) return null;
    return _Rgb(
      _data.getUint8(offset),
      _data.getUint8(offset + 1),
      _data.getUint8(offset + 2),
    );
  }
}

class _Rgb {
  const _Rgb(this.r, this.g, this.b);

  final int r;
  final int g;
  final int b;
}
