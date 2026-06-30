import '../model/target_size_mode.dart';

/// Tunable inputs the rules read while evaluating a snapshot.
///
/// Every field has a sensible default, so `const RuleConfig()` is a complete,
/// zero-configuration setup. Higher layers (the Flutter `AuditConfig`) map their
/// options onto this.
class RuleConfig {
  /// Creates a [RuleConfig].
  const RuleConfig({
    this.placeholderDenylist = defaultPlaceholderDenylist,
    this.targetSizeMode = TargetSizeMode.platform,
    this.platformTargetSize = 48,
  });

  /// Labels treated as non-meaningful placeholders by the placeholder-name rule.
  ///
  /// Compared case-insensitively against a node's trimmed label.
  final Set<String> placeholderDenylist;

  /// Which minimum the target-size rule enforces.
  final TargetSizeMode targetSizeMode;

  /// The platform minimum touch-target size in logical pixels, used when
  /// [targetSizeMode] is [TargetSizeMode.platform]. Defaults to the Material
  /// guidance of 48; set to 44 for iOS.
  final double platformTargetSize;

  /// The minimum acceptable touch-target side, in logical pixels, resolved from
  /// [targetSizeMode] and [platformTargetSize].
  double get minimumTargetSize => switch (targetSizeMode) {
        TargetSizeMode.platform => platformTargetSize,
        TargetSizeMode.wcagMinimum => 24,
      };

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
