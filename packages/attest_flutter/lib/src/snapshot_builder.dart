import 'dart:ui' as ui;

import 'package:attest/attest.dart';
import 'package:flutter/semantics.dart';
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
  SemanticsSnapshot build(SemanticsNode root) =>
      SemanticsSnapshot(root: _convert(root, Matrix4.identity()));

  SemanticsNodeData _convert(SemanticsNode node, Matrix4 parentTransform) {
    final data = node.getSemanticsData();
    final globalTransform = parentTransform.multiplied(
      node.transform ?? Matrix4.identity(),
    );
    final globalRect = MatrixUtils.transformRect(globalTransform, node.rect);

    final children = <SemanticsNodeData>[];
    node.visitChildren((SemanticsNode child) {
      children.add(_convert(child, globalTransform));
      return true;
    });

    return SemanticsNodeData(
      id: node.id,
      label: data.label,
      value: data.value,
      hint: data.hint,
      tooltip: data.tooltip,
      flags: _flags(data.flagsCollection),
      actions: _actions(data),
      bounds: RectData(
        left: globalRect.left,
        top: globalRect.top,
        width: globalRect.width,
        height: globalRect.height,
      ),
      textDirection: data.textDirection == TextDirection.rtl
          ? TextDirectionData.rtl
          : TextDirectionData.ltr,
      childrenInTraversalOrder: children,
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
        if (f.isChecked != ui.CheckedState.none)
          SemanticsFlagData.hasCheckedState,
        if (f.isChecked == ui.CheckedState.isTrue) SemanticsFlagData.isChecked,
        if (f.isToggled != ui.Tristate.none) SemanticsFlagData.hasToggledState,
        if (f.isToggled == ui.Tristate.isTrue) SemanticsFlagData.isToggled,
        if (f.isSelected == ui.Tristate.isTrue) SemanticsFlagData.isSelected,
      };

  Set<SemanticsActionData> _actions(SemanticsData data) => {
        if (data.hasAction(SemanticsAction.tap)) SemanticsActionData.tap,
        if (data.hasAction(SemanticsAction.longPress))
          SemanticsActionData.longPress,
        if (data.hasAction(SemanticsAction.increase))
          SemanticsActionData.increase,
        if (data.hasAction(SemanticsAction.decrease))
          SemanticsActionData.decrease,
        if (data.hasAction(SemanticsAction.scrollLeft))
          SemanticsActionData.scrollLeft,
        if (data.hasAction(SemanticsAction.scrollRight))
          SemanticsActionData.scrollRight,
        if (data.hasAction(SemanticsAction.scrollUp))
          SemanticsActionData.scrollUp,
        if (data.hasAction(SemanticsAction.scrollDown))
          SemanticsActionData.scrollDown,
        if (data.hasAction(SemanticsAction.dismiss))
          SemanticsActionData.dismiss,
      };
}
