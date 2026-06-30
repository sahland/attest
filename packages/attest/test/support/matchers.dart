// Test-only matchers for asserting on findings.

import 'package:attest/attest.dart';
import 'package:test/test.dart';

/// Matches an iterable of [Finding]s that contains one for [ruleId] (and, if
/// given, the [wcag] criterion).
Matcher hasFinding(String ruleId, {String? wcag}) {
  var element = isA<Finding>().having((f) => f.ruleId, 'ruleId', ruleId);
  if (wcag != null) {
    element = element.having((f) => f.criterion.wcag, 'criterion.wcag', wcag);
  }
  return contains(element);
}
