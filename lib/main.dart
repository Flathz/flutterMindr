import 'package:flutter/material.dart';
import 'package:flutter_app/Tabs.dart';

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
          title: Row(children: [
            Text(_title),
            Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Chip(
                  padding: EdgeInsets.all(0),
                  backgroundColor: Colors.red,
                  label: Text('Beta', style: TextStyle(color: Colors.white)),
                )),
          ]),
        ),
        body: Tabs(),
      ),
    );
  }
}
