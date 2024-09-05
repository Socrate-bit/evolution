import 'package:flutter/material.dart';

class ColorsScreen extends StatelessWidget {
  const ColorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.dark().copyWith();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Color Scheme from Seed')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ColorDisplay(color: colorScheme.primary, name: 'Primary'),
              ColorDisplay(color: colorScheme.primaryContainer, name: 'Primary Container'),
              ColorDisplay(color: colorScheme.secondary, name: 'Secondary'),
              ColorDisplay(color: colorScheme.secondaryContainer, name: 'Secondary Container'),
              ColorDisplay(color: colorScheme.background, name: 'Background'),
              ColorDisplay(color: colorScheme.surface, name: 'Surface'),
              ColorDisplay(color: colorScheme.surfaceVariant, name: 'Surface Variant'),
              ColorDisplay(color: colorScheme.error, name: 'Error'),
              ColorDisplay(color: colorScheme.onError, name: 'On Error'),
              ColorDisplay(color: colorScheme.onPrimary, name: 'On Primary'),
              ColorDisplay(color: colorScheme.onSecondary, name: 'On Secondary'),
              ColorDisplay(color: colorScheme.onSurface, name: 'On Surface'),
              ColorDisplay(color: colorScheme.onBackground, name: 'On Background'),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorDisplay extends StatelessWidget {
  final Color color;
  final String name;

  const ColorDisplay({Key? key, required this.color, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
          Container(
            width: 50,
            height: 50,
            color: color,
          ),
          const SizedBox(width: 10),
          Text(
            '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
