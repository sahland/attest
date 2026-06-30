import 'package:flutter/material.dart';

import 'screens.dart';

void main() => runApp(const ExampleApp());

/// The dogfood application: a menu of screens, each demonstrating one
/// accessibility defect attest detects, plus a clean baseline screen.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'attest example',
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

/// Lists the demo screens.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = <(String, WidgetBuilder)>[
      ('Interactive name (broken)', (_) => const BrokenInteractiveNameScreen()),
      ('Image alt (broken)', (_) => const BrokenImageAltScreen()),
      ('Placeholder name (broken)', (_) => const BrokenPlaceholderNameScreen()),
      ('Field label (broken)', (_) => const BrokenFieldLabelScreen()),
      ('Target size (broken)', (_) => const BrokenTargetSizeScreen()),
      ('Focus trap (broken)', (_) => const BrokenFocusTrapScreen()),
      ('Ambiguous name (broken)', (_) => const BrokenAmbiguousNameScreen()),
      ('Clean', (_) => const CleanScreen()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('attest example')),
      body: ListView(
        children: [
          for (final (title, builder) in entries)
            ListTile(
              title: Text(title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: builder)),
            ),
        ],
      ),
    );
  }
}
