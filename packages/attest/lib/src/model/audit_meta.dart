import 'package:meta/meta.dart';

/// Context describing how and when an [AuditReport] was produced.
@immutable
class AuditMeta {
  /// Creates an [AuditMeta].
  const AuditMeta({
    required this.screenName,
    required this.standard,
    required this.toolVersion,
    required this.timestamp,
  });

  /// A human-readable name for the audited screen, e.g. `CheckoutScreen`.
  final String screenName;

  /// The identifier of the standard pack the audit ran against, e.g.
  /// `en301549_v3_2_1`.
  final String standard;

  /// The version of attest that produced the report.
  final String toolVersion;

  /// When the report was produced (UTC).
  final DateTime timestamp;

  /// Parses an [AuditMeta] from [json].
  factory AuditMeta.fromJson(Map<String, dynamic> json) => AuditMeta(
        screenName: json['screenName'] as String,
        standard: json['standard'] as String,
        toolVersion: json['toolVersion'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  /// The JSON representation of this metadata.
  Map<String, dynamic> toJson() => {
        'screenName': screenName,
        'standard': standard,
        'toolVersion': toolVersion,
        'timestamp': timestamp.toUtc().toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      other is AuditMeta &&
      other.screenName == screenName &&
      other.standard == standard &&
      other.toolVersion == toolVersion &&
      other.timestamp == timestamp;

  @override
  int get hashCode => Object.hash(screenName, standard, toolVersion, timestamp);

  @override
  String toString() => 'AuditMeta(screen: $screenName, standard: $standard, '
      'tool: $toolVersion)';
}
