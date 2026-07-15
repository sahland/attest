import 'package:attest/attest.dart';
import 'package:flutter_test/flutter_test.dart';

/// Matches an [AuditReport] that passes its gate: no finding at or above the
/// report's configured gate severity.
///
/// On failure the description is a grouped, criterion-tagged, source-located
/// summary rather than an object dump.
Matcher passesAccessibilityGate() => const _PassesAccessibilityGate();

/// Matches an [AuditReport] with no findings at all, regardless of severity.
Matcher hasNoAccessibilityViolations() => const _HasNoAccessibilityViolations();

/// Matches an [AuditReport] with no finding citing the given [wcag] success
/// criterion, e.g. `'1.4.3'`.
Matcher hasNoViolationsForCriterion(String wcag) =>
    _HasNoViolationsForCriterion(wcag);

abstract class _ReportMatcher extends Matcher {
  const _ReportMatcher();

  /// The findings that make [report] fail this matcher.
  List<Finding> offendingFindings(AuditReport report);

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is! AuditReport) return false;
    return offendingFindings(item).isEmpty;
  }

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is! AuditReport) {
      return mismatchDescription.add('was not an AuditReport');
    }
    return mismatchDescription.add(
      '\n${_render(item, offendingFindings(item))}',
    );
  }
}

class _PassesAccessibilityGate extends _ReportMatcher {
  const _PassesAccessibilityGate();

  @override
  List<Finding> offendingFindings(AuditReport report) =>
      report.gateFailures.toList();

  @override
  Description describe(Description description) =>
      description.add('passes the accessibility gate');
}

class _HasNoAccessibilityViolations extends _ReportMatcher {
  const _HasNoAccessibilityViolations();

  @override
  List<Finding> offendingFindings(AuditReport report) => report.findings;

  @override
  Description describe(Description description) =>
      description.add('has no accessibility violations');
}

class _HasNoViolationsForCriterion extends _ReportMatcher {
  const _HasNoViolationsForCriterion(this.wcag);

  final String wcag;

  @override
  List<Finding> offendingFindings(AuditReport report) =>
      report.findings.where((f) => f.criterion.wcag == wcag).toList();

  @override
  Description describe(Description description) =>
      description.add('has no accessibility violations for WCAG $wcag');
}

String _render(AuditReport report, List<Finding> findings) {
  final plural = findings.length == 1 ? '' : 's';
  final buffer = StringBuffer()
    ..writeln(
      '${report.meta.screenName} — ${findings.length} accessibility '
      'violation$plural (gate: ${report.gateSeverity.name})',
    )
    ..writeln();
  for (final finding in findings) {
    buffer
      ..writeln(
        '  ✗ [${finding.severity.name}] ${finding.ruleId} — '
        '${finding.criterion}',
      )
      ..writeln('    ${finding.message}');
    if (finding.location != null) {
      buffer.writeln('    ${finding.location}');
    }
    buffer.writeln('    Fix: ${finding.suggestion}');
    final code = finding.codeExample;
    if (code != null) {
      for (final line in code.split('\n')) {
        buffer.writeln('      $line');
      }
    }
    final understanding = finding.criterion.understanding;
    if (understanding != null) {
      buffer.writeln('    Learn: $understanding');
    }
    buffer.writeln();
  }
  return buffer.toString().trimRight();
}
