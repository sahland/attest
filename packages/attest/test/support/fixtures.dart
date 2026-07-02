// Concise builders for hand-made [SemanticsSnapshot] fixtures, so rule tests
// read like the trees they describe. Test-only; not part of the public API.

import 'package:attest/attest.dart';

// Short aliases for the flags and actions tests reach for most.
const SemanticsFlagData isButton = SemanticsFlagData.isButton;
const SemanticsFlagData isLink = SemanticsFlagData.isLink;
const SemanticsFlagData isImage = SemanticsFlagData.isImage;
const SemanticsFlagData isTextField = SemanticsFlagData.isTextField;
const SemanticsFlagData isHeader = SemanticsFlagData.isHeader;
const SemanticsFlagData isHidden = SemanticsFlagData.isHidden;
const SemanticsFlagData isEnabled = SemanticsFlagData.isEnabled;
const SemanticsFlagData hasCheckedState = SemanticsFlagData.hasCheckedState;
const SemanticsFlagData isChecked = SemanticsFlagData.isChecked;
const SemanticsFlagData hasToggledState = SemanticsFlagData.hasToggledState;
const SemanticsFlagData isToggled = SemanticsFlagData.isToggled;
const SemanticsFlagData isSelected = SemanticsFlagData.isSelected;

const SemanticsActionData tap = SemanticsActionData.tap;
const SemanticsActionData longPress = SemanticsActionData.longPress;

int _nextId = 0;

/// Builds a [SemanticsNodeData] with an auto-assigned id, defaulting every field
/// so a test sets only what it is exercising.
SemanticsNodeData node({
  String? identifier,
  String label = '',
  String value = '',
  String hint = '',
  String tooltip = '',
  Set<SemanticsFlagData> flags = const {},
  Set<SemanticsActionData> actions = const {},
  RectData bounds = const RectData(left: 0, top: 0, width: 48, height: 48),
  TextDirectionData textDirection = TextDirectionData.ltr,
  List<SemanticsNodeData> children = const [],
  SourceLocation? creator,
  TextStyleData? textStyle,
  int? id,
}) {
  return SemanticsNodeData(
    id: id ?? ++_nextId,
    identifier: identifier,
    label: label,
    value: value,
    hint: hint,
    tooltip: tooltip,
    flags: flags,
    actions: actions,
    bounds: bounds,
    textDirection: textDirection,
    childrenInTraversalOrder: children,
    creator: creator,
    textStyle: textStyle,
  );
}

/// Wraps [root] in a snapshot.
SemanticsSnapshot snap(
  SemanticsNodeData root, {
  List<ContrastSample> contrastSamples = const [],
  List<TextScaleObservation> textScaleObservations = const [],
}) {
  return SemanticsSnapshot(
    root: root,
    contrastSamples: contrastSamples,
    textScaleObservations: textScaleObservations,
  );
}

/// A terse [RectData].
RectData rect(double left, double top, double width, double height) =>
    RectData(left: left, top: top, width: width, height: height);

/// Evaluates [rule] over [snapshot] with a freshly built context, returning the
/// findings as a list.
List<Finding> evaluate(
  Rule rule,
  SemanticsSnapshot snapshot, {
  RuleConfig config = const RuleConfig(),
}) {
  final context = RuleContext(
    config: config,
    index: SnapshotIndex.build(snapshot),
  );
  return rule.evaluate(snapshot, context).toList();
}
