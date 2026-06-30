/// A boolean semantic property of a node, mirrored from Flutter's
/// `SemanticsFlag` so the core can reason about roles and states without any
/// Flutter dependency.
///
/// Only the flags the rule engine consults are modelled; the snapshot builder
/// drops the rest. New values are added as rules come to need them.
enum SemanticsFlagData {
  /// The node is a button.
  isButton,

  /// The node is a link.
  isLink,

  /// The node is an image.
  isImage,

  /// The node is a text input field.
  isTextField,

  /// The node is a heading.
  isHeader,

  /// The node is hidden from the user (and so from assistive technology).
  isHidden,

  /// The node is enabled, i.e. not greyed out / inert.
  isEnabled,

  /// The node exposes a checked state (checkbox, radio).
  hasCheckedState,

  /// The node is currently checked. Only meaningful with [hasCheckedState].
  isChecked,

  /// The node exposes an on/off toggled state (switch).
  hasToggledState,

  /// The node is currently toggled on. Only meaningful with [hasToggledState].
  isToggled,

  /// The node exposes a selected state (tab, chip).
  isSelected;

  /// Parses a [SemanticsFlagData] from its [name].
  static SemanticsFlagData fromJson(String json) =>
      SemanticsFlagData.values.byName(json);

  /// The JSON representation of this flag (its [name]).
  String toJson() => name;
}
