import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'contrast_sample.dart';
import 'semantics_node_data.dart';
import 'text_scale_observation.dart';

const DeepCollectionEquality _deepEquality = DeepCollectionEquality();

/// A serializable, Flutter-free snapshot of one screen's semantics tree plus the
/// observations the Flutter collectors gather.
///
/// This is the single input every rule operates on. The tree ([root]) is always
/// present; [contrastSamples] and [textScaleObservations] are populated only when
/// the corresponding Flutter collectors ran, and are empty in a pure-Dart test.
@immutable
class SemanticsSnapshot {
  /// Creates a [SemanticsSnapshot] from its [root] node and optional
  /// observations.
  const SemanticsSnapshot({
    required this.root,
    this.contrastSamples = const [],
    this.textScaleObservations = const [],
  });

  /// The root of the semantics tree.
  final SemanticsNodeData root;

  /// Contrast measurements gathered by the raster collector, if any.
  final List<ContrastSample> contrastSamples;

  /// Overflow observations gathered by the text-scale collector, if any.
  final List<TextScaleObservation> textScaleObservations;

  /// Every node in the tree, in pre-order (root first).
  Iterable<SemanticsNodeData> get allNodes => root.selfAndDescendants;

  /// Returns a copy with the given observation lists replaced, used to enrich a
  /// tree snapshot with collector output.
  SemanticsSnapshot copyWith({
    List<ContrastSample>? contrastSamples,
    List<TextScaleObservation>? textScaleObservations,
  }) =>
      SemanticsSnapshot(
        root: root,
        contrastSamples: contrastSamples ?? this.contrastSamples,
        textScaleObservations:
            textScaleObservations ?? this.textScaleObservations,
      );

  /// Parses a [SemanticsSnapshot] from [json].
  factory SemanticsSnapshot.fromJson(Map<String, dynamic> json) =>
      SemanticsSnapshot(
        root: SemanticsNodeData.fromJson(json['root'] as Map<String, dynamic>),
        contrastSamples: [
          for (final s
              in (json['contrastSamples'] as List<dynamic>? ?? const []))
            ContrastSample.fromJson(s as Map<String, dynamic>),
        ],
        textScaleObservations: [
          for (final o
              in (json['textScaleObservations'] as List<dynamic>? ?? const []))
            TextScaleObservation.fromJson(o as Map<String, dynamic>),
        ],
      );

  /// The JSON representation of this snapshot.
  Map<String, dynamic> toJson() => {
        'root': root.toJson(),
        if (contrastSamples.isNotEmpty)
          'contrastSamples': [for (final s in contrastSamples) s.toJson()],
        if (textScaleObservations.isNotEmpty)
          'textScaleObservations': [
            for (final o in textScaleObservations) o.toJson(),
          ],
      };

  @override
  bool operator ==(Object other) =>
      other is SemanticsSnapshot &&
      other.root == root &&
      _deepEquality.equals(other.contrastSamples, contrastSamples) &&
      _deepEquality.equals(
        other.textScaleObservations,
        textScaleObservations,
      );

  @override
  int get hashCode => Object.hash(
        root,
        _deepEquality.hash(contrastSamples),
        _deepEquality.hash(textScaleObservations),
      );

  @override
  String toString() => 'SemanticsSnapshot(nodes: ${allNodes.length}, '
      'contrastSamples: ${contrastSamples.length}, '
      'textScaleObservations: ${textScaleObservations.length})';
}
