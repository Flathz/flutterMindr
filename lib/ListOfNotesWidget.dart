import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'MOCK.dart';
import 'models/Note.dart';

/// This is the stateful widget that the main application instantiates.
class ListOfNotesWidget extends StatefulWidget {
  ListOfNotesWidget({Key key}) : super(key: key);

  @override
  _ListOfNotesWidgetState createState() => _ListOfNotesWidgetState();
}

/// This is the private State class that goes with ListOfNotesWidget.
class _ListOfNotesWidgetState extends State<ListOfNotesWidget> {
  final List<Note> _items = list;

  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final oddItemColor = colorScheme.primary.withOpacity(0.05);
    final evenItemColor = colorScheme.primary.withOpacity(0.15);

    return ReorderableListView(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      children: <Widget>[
        for (int index = 0; index < _items.length; index++)
          Card(
            key: Key('$index'),
            child: ListTile(
              tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
              onTap: () => GestureTapCallback,
              leading: Icon(Icons.notes_rounded),
              trailing: Icon(Icons.delete),
              title: Text('Item ${_items[index]}'),
              subtitle: Text('Item description ${_items[index]}'),
            ),
          ),
      ],
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final Note item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
        });
      },
    );
  }
}
