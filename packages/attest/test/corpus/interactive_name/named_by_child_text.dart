import 'package:attest/attest.dart';
import 'package:attest/corpus.dart';

import '../../support/fixtures.dart';

/// Adversarial: the button carries no label of its own, but a child text node
/// supplies the accessible name (the common `ElevatedButton(child: Text('Pay'))`
/// shape). A naive check that only reads the node's own label would false-
/// positive here; the rule must stay silent.
final CorpusCase namedByChildText = CorpusCase(
  id: 'interactive_name/named_by_child_text',
  category: CorpusCategory.adversarial,
  standard: Standard.en301549_v3_2_1,
  ruleUnderTest: 'attest/interactive-name',
  build: () => snap(
    node(
      identifier: 'subject.pay-button',
      flags: {isButton},
      actions: {tap},
      children: [node(label: 'Pay')],
    ),
  ),
);
