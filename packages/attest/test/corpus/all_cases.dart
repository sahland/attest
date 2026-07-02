// The registry of pure-Dart corpus cases in the core package.
//
// Dart has no reflection, so cases are listed explicitly here. Add a new case
// file under `corpus/<rule>/<case>.dart`, then append its case to [corpusCases].
// Widget-based (real-world) cases live in `attest_flutter` and feed the same
// harness with a snapshot built from a pumped widget.

import 'package:attest/corpus.dart';

import 'interactive_name/labeled_button.dart';
import 'interactive_name/named_by_child_text.dart';
import 'interactive_name/unnamed_button.dart';

/// Every pure-Dart corpus case, in a stable order.
final List<CorpusCase> corpusCases = [
  unnamedButton,
  labeledButton,
  namedByChildText,
];
