import 'package:attest/attest.dart';
import 'package:meta/meta.dart';

/// Renders a human-facing HTML summary of an audit, grouped by screen.
@experimental
class HtmlWriter {
  /// Creates an [HtmlWriter].
  const HtmlWriter();

  /// Builds the HTML document for [reports], highlighting the [gate] outcome and,
  /// when a [trend] is given, the change since the previous run.
  String write(List<AuditReport> reports, GateResult gate, {RunDelta? trend}) {
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
      ..writeln(_trend(trend))
      ..writeln(
        '<p class="disclaimer">Automated checks cover machine-checkable '
        'criteria only; a human must review the rest. This is not a claim of '
        'conformance.</p>',
      );

    final newFingerprints = {
      for (final finding in gate.newFindings) finding.fingerprint,
    };

    final hasFindings = reports.any((r) => r.findings.isNotEmpty);
    buffer.writeln('<h2>Automated findings</h2>');
    if (!hasFindings) {
      buffer.writeln(
        '<p class="clean">No automated findings. This is not conformance — '
        'complete the manual checklist below.</p>',
      );
    }
    for (final report in reports) {
      if (report.findings.isEmpty) continue;
      buffer.writeln('<h3>${_escape(report.meta.screenName)}</h3>');
      for (final finding in report.findings) {
        buffer.writeln(
          _finding(finding, newFingerprints.contains(finding.fingerprint)),
        );
      }
    }

    buffer
      ..writeln(_checklist(_packOf(reports)))
      ..writeln('</body></html>');
    return buffer.toString();
  }

  /// The standard pack the [reports] were audited under, defaulting to
  /// EN 301 549 v3.2.1 when it cannot be read.
  Standard _packOf(List<AuditReport> reports) {
    for (final report in reports) {
      try {
        return Standard.fromJson(report.meta.standard);
      } on ArgumentError {
        continue;
      }
    }
    return Standard.en301549_v3_2_1;
  }

  /// The generated manual-review checklist: the criteria attest cannot fully
  /// verify, so the report is a complete audit trail rather than an implied
  /// all-clear.
  String _checklist(Standard standard) {
    final matrix = CoverageMatrix.forStandard(standard);
    final buffer = StringBuffer()
      ..writeln(
        '<h2>Manual review checklist — ${_escape(standard.toJson())}</h2>',
      )
      ..writeln(
        '<p class="disclaimer">attest verifies '
        '${matrix.count(CoverageStatus.automated)} criteria automatically and '
        '${matrix.count(CoverageStatus.partial)} in part. The '
        '${matrix.count(CoverageStatus.manual)} items below require human review '
        'to complete the audit against this standard.</p>',
      );

    const headings = {
      CoverageStatus.partial: 'Partially automated — verify the remainder',
      CoverageStatus.manual: 'Manual',
    };
    for (final entry in headings.entries) {
      final group = matrix.withStatus(entry.key).toList();
      if (group.isEmpty) continue;
      buffer
        ..writeln('<h3>${entry.value}</h3>')
        ..writeln('<ul class="checklist">');
      for (final row in group) {
        buffer.writeln(_checklistRow(row));
      }
      buffer.writeln('</ul>');
    }
    return buffer.toString();
  }

  String _checklistRow(CriterionCoverage row) {
    final c = row.criterion;
    final rules = row.ruleIds.isEmpty
        ? ''
        : ' <span class="rules">(${_escape(row.ruleIds.join(', '))})</span>';
    return '<li><label><input type="checkbox"> '
        '<strong>${_escape(c.wcag)} ${_escape(c.wcagLevel)}</strong> '
        '${_escape(c.title)}$rules</label>'
        '<p class="guidance">${_escape(row.guidance)}</p></li>';
  }

  /// A compact trend banner: the current total and how it moved since the
  /// previous run. Empty when no trend was recorded.
  String _trend(RunDelta? trend) {
    if (trend == null) return '';
    final total = trend.current.total;
    final noun = total == 1 ? 'finding' : 'findings';
    if (!trend.hasPrevious) {
      return '<p class="trend flat">Trend: $total $noun · first recorded '
          'run</p>';
    }
    final change = trend.totalDelta;
    final cls = change < 0
        ? 'down'
        : change > 0
            ? 'up'
            : 'flat';
    final text = change == 0
        ? 'no change since last run'
        : change < 0
            ? '▼ ${-change} since last run'
            : '▲ $change since last run';
    return '<p class="trend $cls">Trend: $total $noun · $text</p>';
  }

  String _finding(Finding finding, bool isNew) {
    final location = finding.location;
    final code = finding.codeExample;
    final example = code == null
        ? ''
        : '<pre class="code"><code>${_escape(code)}</code></pre>';
    final understanding = finding.criterion.understanding;
    final learn = understanding == null
        ? ''
        : '<p class="learn"><a href="${_escape(understanding)}" '
            'target="_blank" rel="noopener">Understanding '
            '${_escape(finding.criterion.wcag)} '
            '${_escape(finding.criterion.title)} →</a></p>';
    return '<div class="finding ${finding.severity.name}">'
        '<span class="badge">${finding.severity.name}</span>'
        '${isNew ? '<span class="new">new</span>' : ''}'
        '<code>${_escape(finding.ruleId)}</code> '
        '<span class="criterion">${_escape(finding.criterion.toString())}</span>'
        '<p>${_escape(finding.message)}</p>'
        '${location == null ? '' : '<p class="loc">${_escape(location.toString())}</p>'}'
        '<p class="fix">Fix: ${_escape(finding.suggestion)}</p>'
        '$example'
        '$learn'
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
      '.fix{color:#137333}.loc{color:#555;font-family:monospace}'
      '.trend{font-weight:600;margin:.25rem 0 .75rem}'
      '.trend.down{color:#137333}.trend.up{color:#c5221f}.trend.flat{color:#555}'
      '.learn{margin:.25rem 0 0}.learn a{color:#1a73e8}'
      'pre.code{background:#1e1e1e;color:#e8e8e8;padding:.6rem .8rem;'
      'border-radius:4px;overflow-x:auto;font-size:.8rem;line-height:1.4;'
      'margin:.4rem 0}pre.code code{font-family:ui-monospace,monospace}'
      'h3{font-size:1rem;margin-top:1.2rem;color:#333}.clean{color:#137333}'
      'ul.checklist{list-style:none;padding-left:0}'
      'ul.checklist li{border-left:4px solid #1a73e8;background:#f3f7ff;'
      'padding:.5rem .75rem;margin:.4rem 0}'
      'ul.checklist label{font-weight:600;cursor:pointer}'
      '.guidance{color:#444;margin:.25rem 0 0 1.4rem}'
      '.rules{color:#555;font-weight:400;font-family:monospace}';

  String _escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
