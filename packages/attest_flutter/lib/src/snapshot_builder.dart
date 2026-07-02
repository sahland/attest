import 'dart:ui' as ui;

import 'package:attest/attest.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Converts a live Flutter [SemanticsNode] tree into a serializable, Flutter-free
/// [SemanticsSnapshot] that the pure-Dart rule engine can evaluate.
///
/// Only the fields the rules consult are carried over; everything else in the
/// live tree is dropped. Bounds are resolved to global logical pixels by
/// accumulating each node's transform from the root.
class SemanticsSnapshotBuilder {
  /// Creates a [SemanticsSnapshotBuilder].
  const SemanticsSnapshotBuilder();

  /// Builds a snapshot rooted at [root].
  ///
  /// Accumulated semantics transforms yield physical-pixel bounds; pass the
  /// view's [devicePixelRatio] so bounds are stored in logical pixels, which is
  /// what the geometry rules (and developers) reason about. Pass [renderRoot]
  /// (the corresponding render tree root) to recover each node's source location
  /// from the widget that created it.
  SemanticsSnapshot build(
    SemanticsNode root, {
    double devicePixelRatio = 1.0,
    RenderObject? renderRoot,
  }) {
    final locations = renderRoot == null
        ? null
        : _LocationIndex.build(renderRoot);
    return SemanticsSnapshot(
      root: _convert(root, Matrix4.identity(), devicePixelRatio, locations),
    );
  }

  SemanticsNodeData _convert(
    SemanticsNode node,
    Matrix4 parentTransform,
    double devicePixelRatio,
    _LocationIndex? locations,
  ) {
    final data = node.getSemanticsData();
    final globalTransform = parentTransform.multiplied(
      node.transform ?? Matrix4.identity(),
    );
    final physicalRect = MatrixUtils.transformRect(globalTransform, node.rect);

    // Use the real traversal order (sort keys + geometry), not the raw child
    // order that `visitChildren` returns, so the focus-order rule sees what
    // assistive technology actually announces.
    final children = [
      for (final child in node.debugListChildrenInOrder(
        DebugSemanticsDumpOrder.traversalOrder,
      ))
        _convert(child, globalTransform, devicePixelRatio, locations),
    ];

    return SemanticsNodeData(
      id: node.id,
      identifier: data.identifier.isEmpty ? null : data.identifier,
      label: data.label,
      value: data.value,
      hint: data.hint,
      tooltip: data.tooltip,
      flags: _flags(data.flagsCollection),
      actions: _actions(data),
      bounds: RectData(
        left: physicalRect.left / devicePixelRatio,
        top: physicalRect.top / devicePixelRatio,
        width: physicalRect.width / devicePixelRatio,
        height: physicalRect.height / devicePixelRatio,
      ),
      textDirection: data.textDirection == TextDirection.rtl
          ? TextDirectionData.rtl
          : TextDirectionData.ltr,
      childrenInTraversalOrder: children,
      creator: locations?.locationFor(node.id),
      textStyle: locations?.textStyleFor(node.id),
    );
  }

  Set<SemanticsFlagData> _flags(ui.SemanticsFlags f) => {
    if (f.isButton) SemanticsFlagData.isButton,
    if (f.isLink) SemanticsFlagData.isLink,
    if (f.isImage) SemanticsFlagData.isImage,
    if (f.isTextField) SemanticsFlagData.isTextField,
    if (f.isHeader) SemanticsFlagData.isHeader,
    if (f.isHidden) SemanticsFlagData.isHidden,
    if (f.isEnabled == ui.Tristate.isTrue) SemanticsFlagData.isEnabled,
    if (f.isChecked != ui.CheckedState.none) SemanticsFlagData.hasCheckedState,
    if (f.isChecked == ui.CheckedState.isTrue) SemanticsFlagData.isChecked,
    if (f.isToggled != ui.Tristate.none) SemanticsFlagData.hasToggledState,
    if (f.isToggled == ui.Tristate.isTrue) SemanticsFlagData.isToggled,
    if (f.isSelected == ui.Tristate.isTrue) SemanticsFlagData.isSelected,
  };

  Set<SemanticsActionData> _actions(SemanticsData data) => {
    if (data.hasAction(SemanticsAction.tap)) SemanticsActionData.tap,
    if (data.hasAction(SemanticsAction.longPress))
      SemanticsActionData.longPress,
    if (data.hasAction(SemanticsAction.increase)) SemanticsActionData.increase,
    if (data.hasAction(SemanticsAction.decrease)) SemanticsActionData.decrease,
    if (data.hasAction(SemanticsAction.scrollLeft))
      SemanticsActionData.scrollLeft,
    if (data.hasAction(SemanticsAction.scrollRight))
      SemanticsActionData.scrollRight,
    if (data.hasAction(SemanticsAction.scrollUp)) SemanticsActionData.scrollUp,
    if (data.hasAction(SemanticsAction.scrollDown))
      SemanticsActionData.scrollDown,
    if (data.hasAction(SemanticsAction.dismiss)) SemanticsActionData.dismiss,
  };
}

/// Maps semantics node ids back to render-tree facts the snapshot cannot carry
/// on its own: the source location of the creating widget, and the text style of
/// text nodes.
///
/// This relies on `--track-widget-creation` (on by default under `flutter
/// test`) and on debug-only render-tree state, so it is strictly best-effort:
/// any failure yields a null result rather than an error.
class _LocationIndex {
  _LocationIndex(this._renderObjectsByNodeId, this._textStylesByNodeId);

  factory _LocationIndex.build(RenderObject root) {
    final byNodeId = <int, RenderObject>{};
    final styles = <int, TextStyleData>{};
    void visit(RenderObject renderObject) {
      final node = renderObject.debugSemantics;
      if (node != null) {
        byNodeId.putIfAbsent(node.id, () => renderObject);
        if (renderObject is RenderParagraph) {
          styles.putIfAbsent(node.id, () => _styleOf(renderObject));
        }
      }
      renderObject.visitChildren(visit);
    }

    visit(root);
    return _LocationIndex(byNodeId, styles);
  }

  final Map<int, RenderObject> _renderObjectsByNodeId;
  final Map<int, TextStyleData> _textStylesByNodeId;

  static final RegExp _pattern = RegExp(
    r'([\w./:\\-]+\.dart):(\d+)(?::(\d+))?',
  );

  static TextStyleData _styleOf(RenderParagraph paragraph) {
    final style = paragraph.text.style;
    return TextStyleData(
      fontSize: style?.fontSize,
      fontWeight: style?.fontWeight?.value,
    );
  }

  TextStyleData? textStyleFor(int nodeId) => _textStylesByNodeId[nodeId];

  SourceLocation? locationFor(int nodeId) {
    final renderObject = _renderObjectsByNodeId[nodeId];
    final creator = renderObject?.debugCreator;
    if (creator is! DebugCreator) return null;
    try {
      // Walk up from the creating element, preferring the first location in the
      // user's own code over a framework or package internal (e.g. the widget
      // that wraps a Material control). Fall back to the nearest location found.
      SourceLocation? firstResolved;
      Element? element = creator.element;
      for (var hops = 0; element != null && hops < 64; hops++) {
        final location = _locationOf(element);
        if (location != null) {
          firstResolved ??= location;
          if (_isLocal(location.file)) return location;
        }
        Element? parent;
        element.visitAncestorElements((ancestor) {
          parent = ancestor;
          return false;
        });
        element = parent;
      }
      return firstResolved;
    } on Object {
      // Best-effort: any failure simply leaves the location unresolved.
      return null;
    }
  }

  SourceLocation? _locationOf(Element element) {
    for (final node in debugTransformDebugCreator([
      DiagnosticsDebugCreator(DebugCreator(element)),
    ])) {
      final location = _search(node);
      if (location != null) return location;
    }
    return null;
  }

  /// Whether [file] is in the user's own code rather than the Flutter SDK or a
  /// pub package.
  static bool _isLocal(String file) {
    if (file.startsWith('package:flutter/') ||
        file.startsWith('package:flutter_test/')) {
      return false;
    }
    final lower = file.toLowerCase();
    return !lower.contains('/hosted/pub.dev/') &&
        !lower.contains(r'\hosted\pub.dev\') &&
        !lower.contains('.pub-cache') &&
        !lower.contains('/flutter/packages/');
  }

  SourceLocation? _search(DiagnosticsNode node) {
    final match = _pattern.firstMatch(node.toString());
    if (match != null) {
      return SourceLocation(
        file: match.group(1)!,
        line: int.parse(match.group(2)!),
        column: match.group(3) == null ? null : int.parse(match.group(3)!),
      );
    }
    for (final child in node.getChildren()) {
      final location = _search(child);
      if (location != null) return location;
    }
    return null;
  }
}
