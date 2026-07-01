import '../model/audit_report.dart';
import '../model/finding.dart';
import '../model/severity.dart';

/// Serializes audit reports to SARIF 2.1.0, the format GitHub and GitLab render
/// as inline annotations on a pull request.
class SarifWriter {
  /// Creates a [SarifWriter].
  const SarifWriter({
    this.toolVersion = '0.0.0',
    this.informationUri = 'https://github.com/sahland/attest',
  });

  /// The attest version recorded as the SARIF tool version.
  final String toolVersion;

  /// The tool's information URI.
  final String informationUri;

  /// Builds the SARIF document for [reports].
  Map<String, dynamic> write(Iterable<AuditReport> reports) {
    final reportList = reports.toList();
    final rules = <String, Map<String, dynamic>>{};
    final ruleIndex = <String, int>{};
    final results = <Map<String, dynamic>>[];

    for (final report in reportList) {
      for (final finding in report.findings) {
        final index = ruleIndex.putIfAbsent(finding.ruleId, () {
          rules[finding.ruleId] = _rule(finding);
          return rules.length - 1;
        });
        results.add(_result(finding, index, report.meta.screenName));
      }
    }

    return {
      r'$schema': 'https://json.schemastore.org/sarif-2.1.0.json',
      'version': '2.1.0',
      'runs': [
        {
          'tool': {
            'driver': {
              'name': 'attest',
              'version': toolVersion,
              'informationUri': informationUri,
              'rules': rules.values.toList(),
            },
          },
          'results': results,
        },
      ],
    };
  }

  Map<String, dynamic> _rule(Finding finding) => {
        'id': finding.ruleId,
        'name': finding.criterion.title,
        'shortDescription': {'text': finding.criterion.title},
        'helpUri': informationUri,
        'properties': {
          'wcag': finding.criterion.wcag,
          'wcagLevel': finding.criterion.wcagLevel,
          'en301549': finding.criterion.en301549,
        },
      };

  Map<String, dynamic> _result(Finding finding, int ruleIndex, String screen) {
    final location = finding.location;
    return {
      'ruleId': finding.ruleId,
      'ruleIndex': ruleIndex,
      'level': _level(finding.severity),
      'message': {'text': finding.message},
      if (location != null)
        'locations': [
          {
            'physicalLocation': {
              'artifactLocation': {'uri': location.file},
              'region': {
                'startLine': location.line,
                if (location.column != null) 'startColumn': location.column,
              },
            },
          },
        ],
      'partialFingerprints': {'attest/v1': finding.fingerprint},
      'properties': {'screen': screen, 'suggestion': finding.suggestion},
    };
  }

  static String _level(Severity severity) => switch (severity) {
        Severity.error => 'error',
        Severity.warning => 'warning',
        Severity.info => 'note',
      };
}
