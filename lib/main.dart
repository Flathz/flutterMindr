import 'package:flutter/material.dart';
import 'package:flutter_app/Tabs.dart';
import 'package:flutter_app/Csv.dart';

void main() => runApp(MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Mindr';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      color: Theme.of(context).colorScheme.primary,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(_title),
        ),
        body: Tabs(),
      ),
    );
  }
}
