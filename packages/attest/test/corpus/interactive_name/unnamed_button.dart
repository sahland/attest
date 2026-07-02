import 'package:attest/attest.dart';
import 'package:attest/corpus.dart';

import '../../support/fixtures.dart';

/// Positive: a tappable button with no accessible name at all. A screen reader
/// announces only "button", so the user cannot tell what it does.
final CorpusCase unnamedButton = CorpusCase(
  id: 'interactive_name/unnamed_button',
  category: CorpusCategory.positive,
  standard: Standard.en301549_v3_2_1,
  ruleUnderTest: 'attest/interactive-name',
  build: () => snap(
    node(
      identifier: 'offender.pay-button',
      flags: {isButton},
      actions: {tap},
    ),
  ),
  expected: const [
    ExpectedFinding(
      ruleId: 'attest/interactive-name',
      wcag: '4.1.2',
      identifier: 'offender.pay-button',
    ),
  ],
);
