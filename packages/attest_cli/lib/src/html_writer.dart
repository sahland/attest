import 'package:attest/attest.dart';
import 'package:meta/meta.dart';

/// Renders a human-facing HTML summary of an audit, grouped by screen.
@experimental
class HtmlWriter {
  /// Creates an [HtmlWriter].
  const HtmlWriter();

  /// Builds the HTML document for [reports], highlighting the [gate] outcome.
  String write(List<AuditReport> reports, GateResult gate) {
    final buffer = StringBuffer()
      ..writeln('<!doctype html>')
      ..writeln('<html lang="en"><head><meta charset="utf-8">')
      ..writeln('<title>attest accessibility report</title>')
      ..writeln('<style>${_style()}</style>')
      ..writeln('</head><body>')
      ..writeln('<h1>attest accessibility report</h1>')
      ..writeln(
        '<p class="summary ${gate.passed ? 'pass' : 'fail'}">'
        '${gate.newFindings.length} new · ${gate.knownFindings.length} known · '
        '${gate.resolvedFingerprints.length} resolved</p>',
      )
      ..writeln(
        '<p class="disclaimer">Automated checks cover machine-checkable '
        'criteria only; a human must review the rest. This is not a claim of '
        'conformance.</p>',
      );

    final newFingerprints = {
      for (final finding in gate.newFindings) finding.fingerprint,
    };

    for (final report in reports) {
      if (report.findings.isEmpty) continue;
      buffer.writeln('<h2>${_escape(report.meta.screenName)}</h2>');
      for (final finding in report.findings) {
        buffer.writeln(
          _finding(finding, newFingerprints.contains(finding.fingerprint)),
        );
      }
    }

    buffer.writeln('</body></html>');
    return buffer.toString();
  }

  String _finding(Finding finding, bool isNew) {
    final location = finding.location;
    return '<div class="finding ${finding.severity.name}">'
        '<span class="badge">${finding.severity.name}</span>'
        '${isNew ? '<span class="new">new</span>' : ''}'
        '<code>${_escape(finding.ruleId)}</code> '
        '<span class="criterion">${_escape(finding.criterion.toString())}</span>'
        '<p>${_escape(finding.message)}</p>'
        '${location == null ? '' : '<p class="loc">${_escape(location.toString())}</p>'}'
        '<p class="fix">Fix: ${_escape(finding.suggestion)}</p>'
        '</div>';
  }

  String _style() =>
      'body{font:14px system-ui,sans-serif;margin:2rem;color:#111}'
      'h1{font-size:1.4rem}h2{font-size:1.1rem;margin-top:1.5rem}'
      '.summary{font-weight:600}.summary.pass{color:#137333}'
      '.summary.fail{color:#c5221f}.disclaimer{color:#555}'
      '.finding{border-left:4px solid #ccc;padding:.5rem .75rem;margin:.5rem 0;'
      'background:#f7f7f7}.finding.error{border-color:#c5221f}'
      '.finding.warning{border-color:#e37400}.badge{text-transform:uppercase;'
      'font-size:.7rem;font-weight:700;margin-right:.5rem}'
      '.new{background:#c5221f;color:#fff;border-radius:3px;padding:0 .3rem;'
      'font-size:.7rem;margin-right:.5rem}.criterion{color:#555}'
      '.fix{color:#137333}.loc{color:#555;font-family:monospace}';

  String _escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
