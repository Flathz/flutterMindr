import 'package:flutter/material.dart';
import 'package:flutter_app/Tabs.dart';
import 'package:flutter_app/Csv.dart';

void main() => runApp(MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Mindr';
  final Csv csv = Csv();

  Future<bool> handleClick(String value) async {
    switch (value) {
      case 'Export notes':
        return csv.getCsv();
        break;
      case 'Import notes':
        return csv.importCsv();
        break;
      default:
        return false;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      color: Theme.of(context).colorScheme.primary,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(_title),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {'Export notes', 'Import notes'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Tabs(),
      ),
    );
  }
}
