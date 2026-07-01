import 'dart:io';

import 'package:attest_flutter/attest_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('attestVersion matches the package version in pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(match, isNotNull, reason: 'no version: line in pubspec.yaml');
    expect(
      attestVersion,
      match!.group(1),
      reason:
          'attestVersion is stale; update it to the package version so the '
          'tool version in reports and SARIF is correct',
    );
  });
}
