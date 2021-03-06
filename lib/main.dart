/// Flutter code sample for ReorderableListView

import 'package:flutter/material.dart';

import 'ListOfNotesWidget.dart';

void main() => runApp(MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Mindr';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: ListOfNotesWidget(),
      ),
    );
  }
}
