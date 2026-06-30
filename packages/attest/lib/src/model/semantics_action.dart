/// An action a node can perform, mirrored from Flutter's `SemanticsAction` so
/// the core can reason about interactivity without any Flutter dependency.
///
/// Only the actions the rule engine consults are modelled; the snapshot builder
/// drops the rest. New values are added as rules come to need them.
enum SemanticsActionData {
  /// A single tap / click / activation.
  tap,

  /// A long press.
  longPress,

  /// Increment, e.g. a slider step up.
  increase,

  /// Decrement, e.g. a slider step down.
  decrease,

  /// Scroll the content left.
  scrollLeft,

  /// Scroll the content right.
  scrollRight,

  /// Scroll the content up.
  scrollUp,

  /// Scroll the content down.
  scrollDown,

  /// Dismiss the node, e.g. swipe away a snackbar.
  dismiss,

  /// Request input focus.
  focus;

  /// Parses a [SemanticsActionData] from its [name].
  static SemanticsActionData fromJson(String json) =>
      SemanticsActionData.values.byName(json);

  /// The JSON representation of this action (its [name]).
  String toJson() => name;
}
