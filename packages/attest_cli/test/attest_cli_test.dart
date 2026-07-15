import 'package:attest/attest.dart';
import 'package:attest_cli/attest_cli.dart';
import 'package:test/test.dart';

void main() {
  const criterion = Criterion(
    wcag: '4.1.2',
    wcagLevel: 'A',
    en301549: '11.4.1.2',
    title: 'Name, Role, Value',
    understanding:
        'https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html',
  );

  AuditReport reportWith(Finding finding) => AuditReport(
        findings: [finding],
        meta: AuditMeta(
          screenName: 'CheckoutScreen',
          standard: 'en301549_v3_2_1',
          toolVersion: '1.0.0',
          timestamp: DateTime.utc(2026),
        ),
      );

  test('the HTML report renders the code example and learn-more link', () {
    const finding = Finding(
      ruleId: 'attest/interactive-name',
      criterion: criterion,
      severity: Severity.error,
      confidence: Confidence.deterministic,
      message: 'Button has no accessible name.',
      suggestion: 'Give it a tooltip.',
      codeExample: '// Before\nIconButton(icon: Icon(Icons.share))\n'
          "// After\nIconButton(icon: Icon(Icons.share), tooltip: 'Share')",
      fingerprint: 'fp1',
    );
    final report = reportWith(finding);
    final gate = const BaselineGate(Baseline.empty).evaluate(report.findings);

    final html = const HtmlWriter().write([report], gate);

    expect(html, contains('<pre class="code">'));
    expect(html, contains('IconButton'));
    expect(html, contains('name-role-value.html'));
  });

  test('a finding without a code example renders no code block', () {
    const finding = Finding(
      ruleId: 'attest/contrast',
      criterion: criterion,
      severity: Severity.warning,
      confidence: Confidence.deterministic,
      message: 'Low contrast.',
      suggestion: 'Darken the text.',
      fingerprint: 'fp2',
    );
    final report = reportWith(finding);
    final gate = const BaselineGate(Baseline.empty).evaluate(report.findings);

    final html = const HtmlWriter().write([report], gate);

    expect(html, isNot(contains('<pre class="code">')));
  });
}
