// The registry of pure-Dart corpus cases in the core package.
//
// Cases are grouped one file per rule (each exposing a `List<CorpusCase>`) and
// gathered here explicitly — Dart has no reflection. Widget-based (real-world)
// cases live in `attest_flutter` and feed the same harness with a snapshot built
// from a pumped widget.

import 'package:attest/corpus.dart';

import 'ambiguous_name.dart';
import 'contrast.dart';
import 'field_label.dart';
import 'focus_order.dart';
import 'focus_trap.dart';
import 'heading_structure.dart';
import 'image_alt.dart';
import 'interactive_name.dart';
import 'non_text_contrast.dart';
import 'placeholder_name.dart';
import 'real_world.dart';
import 'state_exposed.dart';
import 'target_size.dart';
import 'text_overflow.dart';

/// Every pure-Dart corpus case, in a stable order.
final List<CorpusCase> corpusCases = [
  ...interactiveNameCases,
  ...imageAltCases,
  ...placeholderNameCases,
  ...fieldLabelCases,
  ...targetSizeCases,
  ...focusTrapCases,
  ...ambiguousNameCases,
  ...textOverflowCases,
  ...contrastCases,
  ...headingStructureCases,
  ...focusOrderCases,
  ...stateExposedCases,
  ...nonTextContrastCases,
  ...realWorldCases,
];
