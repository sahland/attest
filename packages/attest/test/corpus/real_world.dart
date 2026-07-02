import 'support.dart';

// WCAG ids used across the composite screens.
const _interactiveName = 'attest/interactive-name';
const _imageAlt = 'attest/image-alt';
const _fieldLabel = 'attest/field-label';
const _headingStructure = 'attest/heading-structure';
const _ambiguousName = 'attest/ambiguous-name';
const _focusTrap = 'attest/focus-trap';
const _stateExposed = 'attest/state-exposed';
const _contrast = 'attest/contrast';
const _textOverflow = 'attest/text-overflow';

TextStyleData _style({double? size, int? weight}) =>
    TextStyleData(fontSize: size, fontWeight: weight);

/// Real-world composite screens: every rule runs and every finding across all of
/// them is labelled. These surface the interactions between rules that isolated
/// fixtures miss. All run under the default EN 301 549 v3.2.1 pack (so the WCAG
/// 2.2-only target-size rule, exercised in isolation elsewhere, does not fire).
final List<CorpusCase> realWorldCases = [
  // 1. A sign-in screen: an unnamed show-password icon button, an email field
  //    labelled only by a hint, and a large title that is not a real heading.
  realWorld(
    'real_world/sign_in_screen',
    snap(
      node(
        children: [
          node(
            identifier: 'rw1.title',
            label: 'Sign in',
            textStyle: _style(size: 28),
            bounds: rect(0, 0, 300, 40),
          ),
          node(
            identifier: 'rw1.email',
            hint: 'Email',
            flags: {isTextField},
            bounds: rect(0, 60, 300, 48),
          ),
          node(
            identifier: 'rw1.password',
            label: 'Password',
            flags: {isTextField},
            bounds: rect(0, 120, 300, 48),
          ),
          node(
            identifier: 'rw1.show_password',
            flags: {isButton},
            actions: {tap},
            bounds: rect(250, 120, 40, 40),
          ),
          node(
            identifier: 'rw1.submit',
            label: 'Sign in',
            flags: {isButton},
            actions: {tap},
            bounds: rect(0, 190, 300, 48),
          ),
        ],
      ),
    ),
    [
      ef(_interactiveName, '4.1.2', 'rw1.show_password'),
      ef(_fieldLabel, '1.3.1', 'rw1.email'),
      ef(_headingStructure, '1.3.1', 'rw1.title'),
    ],
  ),

  // 2. A product card: an unlabeled hero image, a bold price acting as a
  //    heading, and an unnamed favourite icon button.
  realWorld(
    'real_world/product_card',
    snap(
      node(
        children: [
          node(
            identifier: 'rw2.photo',
            flags: {isImage},
            bounds: rect(0, 0, 300, 200),
          ),
          node(
            identifier: 'rw2.rating',
            label: 'Rating: 4 of 5 stars',
            flags: {isImage},
            bounds: rect(0, 210, 100, 20),
          ),
          node(
            identifier: 'rw2.price',
            label: r'$9.99',
            textStyle: _style(size: 22, weight: 700),
            bounds: rect(0, 240, 150, 30),
          ),
          node(
            identifier: 'rw2.add_to_cart',
            label: 'Add to cart',
            flags: {isButton},
            actions: {tap},
            bounds: rect(0, 280, 150, 48),
          ),
          node(
            identifier: 'rw2.favorite',
            flags: {isButton},
            actions: {tap},
            bounds: rect(200, 280, 40, 40),
          ),
        ],
      ),
    ),
    [
      ef(_imageAlt, '1.1.1', 'rw2.photo'),
      ef(_headingStructure, '1.3.1', 'rw2.price'),
      ef(_interactiveName, '4.1.2', 'rw2.favorite'),
    ],
  ),

  // 3. A settings screen: an unlabeled switch and a hand-built segmented control
  //    whose selected state is never exposed.
  realWorld(
    'real_world/settings_screen',
    snap(
      node(
        children: [
          node(
            identifier: 'rw3.wifi',
            label: 'Wi-Fi',
            flags: {hasToggledState},
            bounds: rect(0, 0, 300, 48),
          ),
          node(
            identifier: 'rw3.bluetooth',
            flags: {hasToggledState},
            bounds: rect(0, 60, 300, 48),
          ),
          node(
            bounds: rect(0, 120, 300, 48),
            children: [
              node(
                identifier: 'rw3.tab_day',
                label: 'Day',
                actions: {tap},
                bounds: rect(0, 120, 150, 48),
              ),
              node(
                identifier: 'rw3.tab_week',
                label: 'Week',
                actions: {tap},
                bounds: rect(150, 120, 150, 48),
              ),
            ],
          ),
        ],
      ),
    ),
    [
      ef(_fieldLabel, '1.3.1', 'rw3.bluetooth'),
      ef(_stateExposed, '4.1.2', 'rw3.tab_day'),
      ef(_stateExposed, '4.1.2', 'rw3.tab_week'),
    ],
  ),

  // 4. A bottom navigation bar with two identically-named tabs and a menu button
  //    that is tappable but hidden from assistive technology.
  realWorld(
    'real_world/bottom_nav',
    snap(
      node(
        children: [
          node(
            identifier: 'rw4.home1',
            label: 'Home',
            flags: {isButton},
            actions: {tap},
            bounds: rect(0, 0, 80, 48),
          ),
          node(
            identifier: 'rw4.search',
            label: 'Search',
            flags: {isButton},
            actions: {tap},
            bounds: rect(80, 0, 80, 48),
          ),
          node(
            identifier: 'rw4.home2',
            label: 'Home',
            flags: {isButton},
            actions: {tap},
            bounds: rect(160, 0, 80, 48),
          ),
          node(
            identifier: 'rw4.menu',
            label: 'Menu',
            flags: {isButton, isHidden},
            actions: {tap},
            bounds: rect(0, 60, 80, 48),
          ),
        ],
      ),
    ),
    [
      ef(_ambiguousName, '2.4.6', 'rw4.home1'),
      ef(_ambiguousName, '2.4.6', 'rw4.home2'),
      ef(_focusTrap, '2.1.1', 'rw4.menu'),
    ],
  ),

  // 5. A screen exercising the rendered-output rules: low-contrast text, an
  //    unlabeled image, and a row that overflows at enlarged text.
  realWorld(
    'real_world/rendered_output',
    snap(
      node(
        children: [
          node(
            identifier: 'rw5.image',
            flags: {isImage},
            bounds: rect(0, 0, 300, 200),
          ),
          node(
            identifier: 'rw5.subtitle',
            label: 'Subtitle',
            bounds: rect(0, 210, 200, 20),
          ),
          node(
            id: 500,
            identifier: 'rw5.total_row',
            bounds: rect(0, 240, 300, 48),
            children: [
              node(label: 'Subtotal 1234', bounds: rect(0, 240, 300, 48)),
            ],
          ),
          node(
            identifier: 'rw5.checkout',
            label: 'Checkout',
            flags: {isButton},
            actions: {tap},
            bounds: rect(0, 300, 300, 48),
          ),
        ],
      ),
      contrastSamples: [
        ContrastSample(
          identifier: 'rw5.subtitle',
          label: 'Subtitle',
          foregroundLuminance: 0.0,
          backgroundLuminance: 0.05,
          bounds: rect(0, 210, 200, 20),
          fontSize: 14,
        ),
      ],
      textScaleObservations: [
        const TextScaleObservation(
          textScale: 2.0,
          overflowed: true,
          nodeId: 500,
        ),
      ],
    ),
    [
      ef(_imageAlt, '1.1.1', 'rw5.image'),
      ef(_contrast, '1.4.3', 'rw5.subtitle'),
      ef(_textOverflow, '1.4.4', 'rw5.total_row'),
    ],
  ),
];
