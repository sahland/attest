import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'rect_data.dart';
import 'semantics_action.dart';
import 'semantics_flag.dart';
import 'source_location.dart';
import 'text_direction_data.dart';
import 'text_style_data.dart';

const DeepCollectionEquality _deepEquality = DeepCollectionEquality();

/// One node of a serializable, Flutter-free snapshot of a screen's semantics
/// tree.
///
/// This mirrors the data Flutter exposes through `SemanticsData`, reduced to the
/// fields the rules consult. Every rule is a pure function over a tree of these.
@immutable
class SemanticsNodeData {
  /// Creates a [SemanticsNodeData].
  ///
  /// All textual fields default to the empty string and the collections default
  /// to empty, so a fixture need only set the fields under test.
  const SemanticsNodeData({
    required this.id,
    this.identifier,
    this.label = '',
    this.value = '',
    this.hint = '',
    this.tooltip = '',
    this.flags = const {},
    this.actions = const {},
    this.bounds = RectData.zero,
    this.textDirection = TextDirectionData.ltr,
    this.childrenInTraversalOrder = const [],
    this.creator,
    this.textStyle,
  });

  /// A stable identifier for this node, unique within its snapshot.
  final int id;

  /// The developer-assigned semantics identifier, from
  /// `SemanticsProperties.identifier`, when one was set.
  ///
  /// Unlike [id] (a per-run tree index), this is authored in the widget code
  /// and stable across runs. The validation corpus uses it to anchor an
  /// expected finding to the exact node that should produce it.
  final String? identifier;

  /// The node's accessible name, as a screen reader would announce it.
  final String label;

  /// The node's current value (e.g. the text in a field, a slider's value).
  final String value;

  /// A hint describing what happens when the node is acted upon.
  final String hint;

  /// The node's tooltip, if any.
  final String tooltip;

  /// The boolean semantic properties set on this node.
  final Set<SemanticsFlagData> flags;

  /// The actions this node can perform.
  final Set<SemanticsActionData> actions;

  /// The node's bounding rectangle in global logical pixels.
  final RectData bounds;

  /// The reading direction in effect for this node.
  final TextDirectionData textDirection;

  /// This node's children, in the order assistive technology traverses them.
  final List<SemanticsNodeData> childrenInTraversalOrder;

  /// Where the originating widget was created, when available.
  final SourceLocation? creator;

  /// The text style, populated only when this node paints text.
  final TextStyleData? textStyle;

  /// Whether this node has the given [flag].
  bool hasFlag(SemanticsFlagData flag) => flags.contains(flag);

  /// Whether this node can perform the given [action].
  bool hasAction(SemanticsActionData action) => actions.contains(action);

  /// Whether this node is interactive: it is a button or link, or it responds
  /// to a tap or long press.
  bool get isInteractive =>
      hasFlag(SemanticsFlagData.isButton) ||
      hasFlag(SemanticsFlagData.isLink) ||
      hasAction(SemanticsActionData.tap) ||
      hasAction(SemanticsActionData.longPress);

  /// This node and all of its descendants, in pre-order (self first).
  Iterable<SemanticsNodeData> get selfAndDescendants sync* {
    yield this;
    for (final child in childrenInTraversalOrder) {
      yield* child.selfAndDescendants;
    }
  }

  /// Parses a [SemanticsNodeData] tree from [json].
  factory SemanticsNodeData.fromJson(Map<String, dynamic> json) =>
      SemanticsNodeData(
        id: json['id'] as int,
        identifier: json['identifier'] as String?,
        label: json['label'] as String? ?? '',
        value: json['value'] as String? ?? '',
        hint: json['hint'] as String? ?? '',
        tooltip: json['tooltip'] as String? ?? '',
        flags: {
          for (final f in (json['flags'] as List<dynamic>? ?? const []))
            SemanticsFlagData.fromJson(f as String),
        },
        actions: {
          for (final a in (json['actions'] as List<dynamic>? ?? const []))
            SemanticsActionData.fromJson(a as String),
        },
        bounds: json['bounds'] == null
            ? RectData.zero
            : RectData.fromJson(json['bounds'] as Map<String, dynamic>),
        textDirection: json['textDirection'] == null
            ? TextDirectionData.ltr
            : TextDirectionData.fromJson(json['textDirection'] as String),
        childrenInTraversalOrder: [
          for (final c in (json['children'] as List<dynamic>? ?? const []))
            SemanticsNodeData.fromJson(c as Map<String, dynamic>),
        ],
        creator: json['creator'] == null
            ? null
            : SourceLocation.fromJson(json['creator'] as Map<String, dynamic>),
        textStyle: json['textStyle'] == null
            ? null
            : TextStyleData.fromJson(json['textStyle'] as Map<String, dynamic>),
      );

  /// The JSON representation of this node and its subtree.
  ///
  /// Flag and action sets are emitted as sorted lists so the output is stable.
  Map<String, dynamic> toJson() => {
        'id': id,
        if (identifier != null) 'identifier': identifier,
        if (label.isNotEmpty) 'label': label,
        if (value.isNotEmpty) 'value': value,
        if (hint.isNotEmpty) 'hint': hint,
        if (tooltip.isNotEmpty) 'tooltip': tooltip,
        if (flags.isNotEmpty)
          'flags': (flags.map((f) => f.name).toList()..sort()),
        if (actions.isNotEmpty)
          'actions': (actions.map((a) => a.name).toList()..sort()),
        'bounds': bounds.toJson(),
        'textDirection': textDirection.toJson(),
        if (childrenInTraversalOrder.isNotEmpty)
          'children': [
            for (final c in childrenInTraversalOrder) c.toJson(),
          ],
        if (creator != null) 'creator': creator!.toJson(),
        if (textStyle != null) 'textStyle': textStyle!.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      other is SemanticsNodeData &&
      other.id == id &&
      other.identifier == identifier &&
      other.label == label &&
      other.value == value &&
      other.hint == hint &&
      other.tooltip == tooltip &&
      _deepEquality.equals(other.flags, flags) &&
      _deepEquality.equals(other.actions, actions) &&
      other.bounds == bounds &&
      other.textDirection == textDirection &&
      _deepEquality.equals(
        other.childrenInTraversalOrder,
        childrenInTraversalOrder,
      ) &&
      other.creator == creator &&
      other.textStyle == textStyle;

  @override
  int get hashCode => Object.hash(
        id,
        identifier,
        label,
        value,
        hint,
        tooltip,
        _deepEquality.hash(flags),
        _deepEquality.hash(actions),
        bounds,
        textDirection,
        _deepEquality.hash(childrenInTraversalOrder),
        creator,
        textStyle,
      );

  @override
  String toString() =>
      'SemanticsNodeData(id: $id, label: "$label", flags: $flags, '
      'actions: $actions)';
}
