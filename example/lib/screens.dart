import 'package:flutter/material.dart';

/// A screen with one interactive element that has no accessible name.
///
/// Triggers `attest/interactive-name`: the icon button has neither a tooltip nor
/// a semantic label, so a screen reader announces only "button".
class BrokenInteractiveNameScreen extends StatelessWidget {
  const BrokenInteractiveNameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interactive name')),
      body: Center(
        child: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
      ),
    );
  }
}

/// A screen with an image exposed to semantics but lacking a text alternative.
///
/// Triggers `attest/image-alt`.
class BrokenImageAltScreen extends StatelessWidget {
  const BrokenImageAltScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image alt')),
      body: Center(
        child: Semantics(
          image: true,
          child: Container(width: 96, height: 96, color: Colors.indigo),
        ),
      ),
    );
  }
}

/// A screen whose button is named with a generic placeholder word.
///
/// Triggers `attest/placeholder-name`: the accessible name "Button" passes the
/// presence check but tells the user nothing.
class BrokenPlaceholderNameScreen extends StatelessWidget {
  const BrokenPlaceholderNameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Placeholder name')),
      body: Center(
        child: ElevatedButton(onPressed: () {}, child: const Text('Button')),
      ),
    );
  }
}

/// A screen with an unlabelled form field.
///
/// Triggers `attest/field-label`: the field has no programmatic label (a hint is
/// not a label).
class BrokenFieldLabelScreen extends StatelessWidget {
  const BrokenFieldLabelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Field label')),
      // A bare field with no label: a screen reader announces only "edit box".
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: TextField(),
      ),
    );
  }
}

/// A screen with a touch target smaller than the platform minimum.
///
/// Triggers `attest/target-size`: the tappable box is 24×24, below 48.
class BrokenTargetSizeScreen extends StatelessWidget {
  const BrokenTargetSizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Target size')),
      body: Center(
        child: Semantics(
          button: true,
          label: 'Add item',
          onTap: () {},
          child: const SizedBox(
            width: 24,
            height: 24,
            child: ColoredBox(color: Colors.indigo),
          ),
        ),
      ),
    );
  }
}

/// A screen with an interactive element that is tappable but hidden from
/// assistive technology.
///
/// Triggers `attest/focus-trap`.
class BrokenFocusTrapScreen extends StatelessWidget {
  const BrokenFocusTrapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Focus trap')),
      body: Center(
        child: Semantics(
          button: true,
          label: 'Buy now',
          hidden: true,
          onTap: () {},
          child: const SizedBox(
            width: 96,
            height: 48,
            child: ColoredBox(color: Colors.orange),
          ),
        ),
      ),
    );
  }
}

/// A screen with two interactive elements that share an accessible name.
///
/// Triggers `attest/ambiguous-name`.
class BrokenAmbiguousNameScreen extends StatelessWidget {
  const BrokenAmbiguousNameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ambiguous name')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(onPressed: () {}, child: const Text('More')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('More')),
          ],
        ),
      ),
    );
  }
}

/// A screen whose row fits at the normal text size but overflows when the
/// system font is enlarged.
///
/// Triggers `attest/text-overflow` only under the text-scale pass.
class BrokenTextOverflowScreen extends StatelessWidget {
  const BrokenTextOverflowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text overflow')),
      body: const Center(
        child: SizedBox(
          width: 200,
          child: Row(
            children: [
              Text('Settings overview panel'),
              Icon(Icons.info),
            ],
          ),
        ),
      ),
    );
  }
}

/// A screen whose text is too faint against its background.
///
/// Triggers `attest/contrast` under the raster pass.
class BrokenContrastScreen extends StatelessWidget {
  const BrokenContrastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contrast')),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          'Account balance',
          style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 16),
        ),
      ),
    );
  }
}

/// A screen built correctly: every element has an accessible name.
///
/// Produces no findings, and serves as the audit's clean baseline.
class CleanScreen extends StatelessWidget {
  const CleanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clean')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              image: true,
              label: 'Revenue chart',
              child: Container(width: 96, height: 96, color: Colors.teal),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 240,
              child: TextField(
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () {}, child: const Text('Pay')),
          ],
        ),
      ),
    );
  }
}
