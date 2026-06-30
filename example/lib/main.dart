import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

/// The dogfood application. It will grow one intentionally-broken screen per
/// accessibility rule (plus a few clean screens) as rules are implemented.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'attest example',
      home: Scaffold(
        appBar: AppBar(title: const Text('attest example')),
        body: const Center(
          child: Text('Dogfood screens land with the first rules.'),
        ),
      ),
    );
  }
}
