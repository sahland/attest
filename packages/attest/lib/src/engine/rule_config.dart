/// Tunable inputs the rules read while evaluating a snapshot.
///
/// Every field has a sensible default, so `const RuleConfig()` is a complete,
/// zero-configuration setup. Higher layers (the Flutter `AuditConfig`) map their
/// options onto this.
class RuleConfig {
  /// Creates a [RuleConfig].
  const RuleConfig({this.placeholderDenylist = defaultPlaceholderDenylist});

  /// Labels treated as non-meaningful placeholders by the placeholder-name rule.
  ///
  /// Compared case-insensitively against a node's trimmed label.
  final Set<String> placeholderDenylist;

  /// The built-in placeholder/denylist tokens.
  static const Set<String> defaultPlaceholderDenylist = {
    'button',
    'image',
    'icon',
    'label',
    'text',
    'todo',
    'untitled',
    'flutter',
    'widget',
    'placeholder',
    'title',
    'new item',
  };
}
