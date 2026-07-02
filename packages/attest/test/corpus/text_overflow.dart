import 'support.dart';

const _rule = 'attest/text-overflow';
const _wcag = '1.4.4';

TextScaleObservation _obs(double scale, bool overflowed, int? nodeId) =>
    TextScaleObservation(
      textScale: scale,
      overflowed: overflowed,
      nodeId: nodeId,
    );

/// Corpus for `attest/text-overflow` (WCAG 1.4.4): layout that overflows when
/// the system text size is enlarged. Driven by the text-scale collector's
/// observations; a snapshot with none yields nothing.
final List<CorpusCase> textOverflowCases = [
  // --- positive ---
  positive(
    'text_overflow/overflow_at_2x',
    _rule,
    snap(
      node(children: [node(id: 100, identifier: 'off.row', label: 'Total')]),
      textScaleObservations: [_obs(2.0, true, 100)],
    ),
    [ef(_rule, _wcag, 'off.row')],
  ),
  positive(
    'text_overflow/overflow_at_1_3x',
    _rule,
    snap(
      node(children: [node(id: 101, identifier: 'off.header', label: 'Title')]),
      textScaleObservations: [_obs(1.3, true, 101)],
    ),
    [ef(_rule, _wcag, 'off.header')],
  ),
  positive(
    'text_overflow/unattributed_overflow_hits_root',
    _rule,
    // The collector could not attribute the overflow; it is charged to the root.
    snap(
      node(id: 5, identifier: 'off.screen', label: 'Screen'),
      textScaleObservations: [_obs(2.0, true, null)],
    ),
    [ef(_rule, _wcag, 'off.screen')],
  ),
  positive(
    'text_overflow/overflow_at_multiple_scales_is_one_finding',
    _rule,
    snap(
      node(children: [node(id: 102, identifier: 'off.multi', label: 'Row')]),
      textScaleObservations: [_obs(1.3, true, 102), _obs(2.0, true, 102)],
    ),
    [ef(_rule, _wcag, 'off.multi')],
  ),

  // --- clean ---
  clean(
    'text_overflow/observed_no_overflow',
    _rule,
    snap(
      node(children: [node(id: 200, identifier: 'ok.row', label: 'Total')]),
      textScaleObservations: [_obs(2.0, false, 200)],
    ),
  ),
  clean(
    'text_overflow/no_observations',
    _rule,
    // A pure-Dart snapshot without the text-scale collector: nothing to judge.
    snap(node(identifier: 'ok.none', label: 'Total')),
  ),

  // --- adversarial ---
  adversarial(
    'text_overflow/large_scale_but_fits',
    _rule,
    // A big scale that did not overflow must not be reported.
    snap(
      node(children: [node(id: 300, identifier: 'trap.fit', label: 'Total')]),
      textScaleObservations: [_obs(2.0, false, 300)],
    ),
  ),
  adversarial(
    'text_overflow/multiple_clean_observations',
    _rule,
    snap(
      node(children: [node(id: 301, identifier: 'trap.multi', label: 'Row')]),
      textScaleObservations: [_obs(1.3, false, 301), _obs(2.0, false, 301)],
    ),
  ),
];
