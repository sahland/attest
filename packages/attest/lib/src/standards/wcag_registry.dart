import '../model/criterion.dart';
import 'criterion_coverage.dart';

/// The single source of truth mapping WCAG Level A and AA success criteria to
/// how far attest covers each one.
///
/// It lists every criterion in scope for AA conformance (WCAG 2.1 plus the
/// 2.2 additions), not only the ones a rule checks — the manual rows are the
/// point. `guidance` is attest's own concise paraphrase of intent; it never
/// reproduces the W3C's copyrighted normative wording. EN 301 549 clause
/// numbers follow the v3.2.1 clause-11 mirror (`11.<sc>`), the same convention
/// the bundled rules use.
///
/// WCAG 4.1.1 Parsing is intentionally absent: it was removed in WCAG 2.2 and
/// is not applicable to a rendered Flutter app.
abstract final class WcagRegistry {
  static CriterionCoverage _c(
    String wcag,
    String level,
    String title,
    CoverageStatus status, {
    List<String> rules = const [],
    required String guidance,
  }) =>
      CriterionCoverage(
        criterion: Criterion(
          wcag: wcag,
          wcagLevel: level,
          en301549: '11.$wcag',
          title: title,
        ),
        status: status,
        ruleIds: rules,
        guidance: guidance,
      );

  static const _a = 'attest';

  /// Every Level A / AA success criterion, in success-criterion order.
  static final List<CriterionCoverage> all = [
    // --- 1 Perceivable ---
    _c(
      '1.1.1',
      'A',
      'Non-text Content',
      CoverageStatus.automated,
      rules: ['$_a/image-alt'],
      guidance: 'Flags images exposed to assistive tech with no text '
          'alternative. Whether an existing alt text is meaningful is manual.',
    ),
    _c(
      '1.2.1',
      'A',
      'Audio-only and Video-only (Prerecorded)',
      CoverageStatus.manual,
      guidance: 'Provide a transcript or alternative for prerecorded '
          'audio-only and video-only media.',
    ),
    _c(
      '1.2.2',
      'A',
      'Captions (Prerecorded)',
      CoverageStatus.manual,
      guidance: 'Provide captions for prerecorded video with audio.',
    ),
    _c(
      '1.2.3',
      'A',
      'Audio Description or Media Alternative (Prerecorded)',
      CoverageStatus.manual,
      guidance: 'Describe important visual information in prerecorded video.',
    ),
    _c(
      '1.2.4',
      'AA',
      'Captions (Live)',
      CoverageStatus.manual,
      guidance: 'Provide captions for live audio content.',
    ),
    _c(
      '1.2.5',
      'AA',
      'Audio Description (Prerecorded)',
      CoverageStatus.manual,
      guidance: 'Provide an audio description track for prerecorded video.',
    ),
    _c(
      '1.3.1',
      'A',
      'Info and Relationships',
      CoverageStatus.automated,
      rules: ['$_a/field-label', '$_a/heading-structure'],
      guidance: 'Flags form controls with no programmatic label and headings '
          'not exposed as such. Other structural relationships need review.',
    ),
    _c(
      '1.3.2',
      'A',
      'Meaningful Sequence',
      CoverageStatus.manual,
      guidance: 'The programmatic reading order must match the meaningful '
          'order; confirm it conveys the intended sequence.',
    ),
    _c(
      '1.3.3',
      'A',
      'Sensory Characteristics',
      CoverageStatus.manual,
      guidance: 'Instructions must not rely on shape, size or location '
          'alone (e.g. "the button on the right").',
    ),
    _c(
      '1.3.4',
      'AA',
      'Orientation',
      CoverageStatus.manual,
      guidance: 'Do not lock the app to a single orientation unless '
          'essential.',
    ),
    _c(
      '1.3.5',
      'AA',
      'Identify Input Purpose',
      CoverageStatus.manual,
      guidance: 'Fields collecting known user data should declare autofill '
          'hints so their purpose is programmatic.',
    ),
    _c(
      '1.4.1',
      'A',
      'Use of Color',
      CoverageStatus.manual,
      guidance: 'Colour must not be the only way information is conveyed.',
    ),
    _c(
      '1.4.2',
      'A',
      'Audio Control',
      CoverageStatus.manual,
      guidance: 'Audio that plays automatically for more than 3s must be '
          'pausable or stoppable.',
    ),
    _c(
      '1.4.3',
      'AA',
      'Contrast (Minimum)',
      CoverageStatus.automated,
      rules: ['$_a/contrast'],
      guidance: 'Measures text contrast from rendered pixels against the '
          '4.5:1 / 3:1 minimums.',
    ),
    _c(
      '1.4.4',
      'AA',
      'Resize Text',
      CoverageStatus.automated,
      rules: ['$_a/text-overflow'],
      guidance: 'Re-lays out the screen at enlarged text and flags layout '
          'that overflows or clips.',
    ),
    _c(
      '1.4.5',
      'AA',
      'Images of Text',
      CoverageStatus.manual,
      guidance: 'Use real text rather than images of text where possible.',
    ),
    _c(
      '1.4.10',
      'AA',
      'Reflow',
      CoverageStatus.manual,
      guidance: 'Content must reflow without loss at small viewports; the '
          'text-overflow check touches this but does not fully verify it.',
    ),
    _c(
      '1.4.11',
      'AA',
      'Non-text Contrast',
      CoverageStatus.automated,
      rules: ['$_a/non-text-contrast'],
      guidance: 'Measures icon / graphical contrast from rendered pixels '
          'against the 3:1 minimum.',
    ),
    _c(
      '1.4.12',
      'AA',
      'Text Spacing',
      CoverageStatus.manual,
      guidance: 'No content may be clipped when users increase line, letter '
          'and word spacing.',
    ),
    _c(
      '1.4.13',
      'AA',
      'Content on Hover or Focus',
      CoverageStatus.manual,
      guidance: 'Content shown on hover/focus must be dismissible, hoverable '
          'and persistent.',
    ),

    // --- 2 Operable ---
    _c(
      '2.1.1',
      'A',
      'Keyboard',
      CoverageStatus.partial,
      rules: ['$_a/focus-trap'],
      guidance: 'Flags interactive elements that are tappable but hidden from '
          'assistive tech. Full keyboard operability is otherwise manual.',
    ),
    _c(
      '2.1.2',
      'A',
      'No Keyboard Trap',
      CoverageStatus.manual,
      guidance: 'Focus must be able to move away from every component.',
    ),
    _c(
      '2.1.4',
      'A',
      'Character Key Shortcuts',
      CoverageStatus.manual,
      guidance: 'Single-character shortcuts must be remappable or turn-off-'
          'able.',
    ),
    _c(
      '2.2.1',
      'A',
      'Timing Adjustable',
      CoverageStatus.manual,
      guidance: 'Time limits must be adjustable, extendable or turn-off-'
          'able.',
    ),
    _c(
      '2.2.2',
      'A',
      'Pause, Stop, Hide',
      CoverageStatus.manual,
      guidance: 'Moving, blinking or auto-updating content must be '
          'controllable.',
    ),
    _c(
      '2.3.1',
      'A',
      'Three Flashes or Below Threshold',
      CoverageStatus.manual,
      guidance: 'Nothing may flash more than three times per second.',
    ),
    _c(
      '2.4.1',
      'A',
      'Bypass Blocks',
      CoverageStatus.manual,
      guidance: 'Provide a way to skip repeated blocks of content.',
    ),
    _c(
      '2.4.2',
      'A',
      'Page Titled',
      CoverageStatus.manual,
      guidance: 'Each screen should have a descriptive title.',
    ),
    _c(
      '2.4.3',
      'A',
      'Focus Order',
      CoverageStatus.partial,
      rules: ['$_a/focus-order'],
      guidance: 'A heuristic flags clear upward jumps in traversal order. '
          'Confirm the overall order preserves meaning and operability.',
    ),
    _c(
      '2.4.4',
      'A',
      'Link Purpose (In Context)',
      CoverageStatus.manual,
      guidance: 'A link\'s purpose must be clear from its text or context; '
          'the interactive-name rule only ensures it has a name.',
    ),
    _c(
      '2.4.5',
      'AA',
      'Multiple Ways',
      CoverageStatus.manual,
      guidance: 'Offer more than one way to reach a screen (search, menu, '
          'index).',
    ),
    _c(
      '2.4.6',
      'AA',
      'Headings and Labels',
      CoverageStatus.automated,
      rules: ['$_a/placeholder-name', '$_a/ambiguous-name'],
      guidance: 'Flags placeholder labels and duplicate/ambiguous names. '
          'Whether a descriptive label is apt is manual.',
    ),
    _c(
      '2.4.7',
      'AA',
      'Focus Visible',
      CoverageStatus.manual,
      guidance: 'A visible focus indicator must appear on the focused '
          'element (best verified while interacting).',
    ),
    _c(
      '2.4.11',
      'AA',
      'Focus Not Obscured (Minimum)',
      CoverageStatus.manual,
      guidance: 'The focused element must not be entirely hidden by other '
          'content such as sticky headers.',
    ),
    _c(
      '2.5.1',
      'A',
      'Pointer Gestures',
      CoverageStatus.manual,
      guidance: 'Multipoint or path-based gestures need a single-pointer '
          'alternative.',
    ),
    _c(
      '2.5.2',
      'A',
      'Pointer Cancellation',
      CoverageStatus.manual,
      guidance: 'Actions should fire on the up event and be abortable.',
    ),
    _c(
      '2.5.3',
      'A',
      'Label in Name',
      CoverageStatus.manual,
      guidance: 'A control\'s accessible name must contain its visible label '
          'text so voice control works.',
    ),
    _c(
      '2.5.4',
      'A',
      'Motion Actuation',
      CoverageStatus.manual,
      guidance: 'Motion-triggered actions need a conventional alternative '
          'and a way to disable them.',
    ),
    _c(
      '2.5.7',
      'AA',
      'Dragging Movements',
      CoverageStatus.manual,
      guidance: 'Drag operations need a single-pointer alternative.',
    ),
    _c(
      '2.5.8',
      'AA',
      'Target Size (Minimum)',
      CoverageStatus.automated,
      rules: ['$_a/target-size'],
      guidance: 'Flags touch targets below the minimum size from the node '
          'geometry.',
    ),

    // --- 3 Understandable ---
    _c(
      '3.1.1',
      'A',
      'Language of Page',
      CoverageStatus.manual,
      guidance: 'The default human language of the screen must be set '
          'programmatically.',
    ),
    _c(
      '3.1.2',
      'AA',
      'Language of Parts',
      CoverageStatus.manual,
      guidance: 'Passages in a different language must be marked as such.',
    ),
    _c(
      '3.2.1',
      'A',
      'On Focus',
      CoverageStatus.manual,
      guidance: 'Moving focus to a component must not trigger an unexpected '
          'context change.',
    ),
    _c(
      '3.2.2',
      'A',
      'On Input',
      CoverageStatus.manual,
      guidance: 'Changing a setting must not trigger an unexpected context '
          'change without warning.',
    ),
    _c(
      '3.2.3',
      'AA',
      'Consistent Navigation',
      CoverageStatus.manual,
      guidance: 'Navigation that repeats across screens must stay in a '
          'consistent order.',
    ),
    _c(
      '3.2.4',
      'AA',
      'Consistent Identification',
      CoverageStatus.manual,
      guidance: 'Components with the same function must be identified '
          'consistently.',
    ),
    _c(
      '3.2.6',
      'A',
      'Consistent Help',
      CoverageStatus.manual,
      guidance: 'Help mechanisms must appear in a consistent location '
          'across screens.',
    ),
    _c(
      '3.3.1',
      'A',
      'Error Identification',
      CoverageStatus.manual,
      guidance: 'Input errors must be identified and described in text.',
    ),
    _c(
      '3.3.2',
      'A',
      'Labels or Instructions',
      CoverageStatus.manual,
      guidance: 'Inputs need labels or instructions; the field-label rule '
          'catches missing labels, but their sufficiency is manual.',
    ),
    _c(
      '3.3.3',
      'AA',
      'Error Suggestion',
      CoverageStatus.manual,
      guidance: 'When an error is detected, suggest a correction where '
          'possible.',
    ),
    _c(
      '3.3.4',
      'AA',
      'Error Prevention (Legal, Financial, Data)',
      CoverageStatus.manual,
      guidance: 'Submissions with legal or financial effect must be '
          'reversible, checked or confirmed.',
    ),
    _c(
      '3.3.7',
      'A',
      'Redundant Entry',
      CoverageStatus.manual,
      guidance: 'Do not ask for the same information twice in one process '
          'without auto-populating it.',
    ),
    _c(
      '3.3.8',
      'AA',
      'Accessible Authentication (Minimum)',
      CoverageStatus.manual,
      guidance: 'Do not require a cognitive function test (like solving a '
          'puzzle) to authenticate.',
    ),

    // --- 4 Robust ---
    _c(
      '4.1.2',
      'A',
      'Name, Role, Value',
      CoverageStatus.automated,
      rules: [
        '$_a/interactive-name',
        '$_a/state-exposed',
        '$_a/adjustable-value',
      ],
      guidance: 'Flags interactive elements with no accessible name, custom '
          'controls that never expose their state, and adjustable controls '
          'with no value.',
    ),
    _c(
      '4.1.3',
      'AA',
      'Status Messages',
      CoverageStatus.manual,
      guidance: 'Status messages must be exposed to assistive tech without '
          'moving focus (best verified across interactions).',
    ),
  ];
}
