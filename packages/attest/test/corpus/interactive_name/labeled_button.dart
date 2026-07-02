import 'package:attest/attest.dart';
import 'package:attest/corpus.dart';

import '../../support/fixtures.dart';

/// Clean: a button with a clear accessible name. The rule must stay silent.
final CorpusCase labeledButton = CorpusCase(
  id: 'interactive_name/labeled_button',
  category: CorpusCategory.clean,
  standard: Standard.en301549_v3_2_1,
  ruleUnderTest: 'attest/interactive-name',
  build: () => snap(
    node(
      identifier: 'subject.pay-button',
      label: 'Pay',
      flags: {isButton},
      actions: {tap},
    ),
  ),
);
