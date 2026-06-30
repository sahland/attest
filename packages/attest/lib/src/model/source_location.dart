import 'package:meta/meta.dart';

/// A location in source code, used to anchor a [Finding] to the widget that
/// produced it.
///
/// In debug and test builds Flutter records the `Element` that created each
/// semantics node (via `debugCreator`), from which the snapshot builder recovers
/// the originating widget's file and line.
@immutable
class SourceLocation {
  /// Creates a source location for [file] at [line] (1-based) and optional
  /// [column].
  const SourceLocation({required this.file, required this.line, this.column});

  /// The path to the source file, as reported by Flutter (typically relative to
  /// the package root, e.g. `lib/checkout/pay_button.dart`).
  final String file;

  /// The 1-based line number.
  final int line;

  /// The 1-based column number, when known.
  final int? column;

  /// Parses a [SourceLocation] from [json].
  factory SourceLocation.fromJson(Map<String, dynamic> json) => SourceLocation(
        file: json['file'] as String,
        line: json['line'] as int,
        column: json['column'] as int?,
      );

  /// The JSON representation of this location.
  Map<String, dynamic> toJson() => {
        'file': file,
        'line': line,
        if (column != null) 'column': column,
      };

  @override
  bool operator ==(Object other) =>
      other is SourceLocation &&
      other.file == file &&
      other.line == line &&
      other.column == column;

  @override
  int get hashCode => Object.hash(file, line, column);

  @override
  String toString() => column == null ? '$file:$line' : '$file:$line:$column';
}
