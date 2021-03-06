import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'models/Note.dart';
import 'package:flutter_app/db_helper.dart';

/// This is the stateful widget that the main application instantiates.
class ListOfNotesWidget extends StatefulWidget {
  ListOfNotesWidget({Key key}) : super(key: key);

  @override
  _ListOfNotesWidgetState createState() => _ListOfNotesWidgetState();
}

/// This is the private State class that goes with ListOfNotesWidget.
class _ListOfNotesWidgetState extends State<ListOfNotesWidget> {
  DBHelper dbHelper;
  List<Note> _items = [];
  List<Note> _filterItems = [];

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    dbHelper.getNotes().then((value) {
      setState(() {
        _items = value;
        _filterItems = _items;
      });
    });
  }

  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final oddItemColor = colorScheme.primary.withOpacity(0.05);
    final evenItemColor = colorScheme.primary.withOpacity(0.15);

    return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              hintText: 'Search through note',
            ),
            onChanged: (string) {
              setState(() {
                _filterItems = _items
                    .where((element) =>
                        element.content
                            .toLowerCase()
                            .contains(string.toLowerCase()) ||
                        element.title
                            .toLowerCase()
                            .contains(string.toLowerCase()))
                    .toList();
              });
            },
          ),
          for (int index = 0; index < _filterItems.length; index++)
            Card(
              key: Key('$index'),
              child: ListTile(
                tileColor:
                    _filterItems[index].isOdd ? oddItemColor : evenItemColor,
                onTap: () => GestureTapCallback,
                leading: Icon(Icons.notes_rounded),
                trailing: Icon(Icons.delete),
                title: Text(_filterItems[index].title),
                subtitle: Text(_filterItems[index].content),
              ),
            ),
        ]);
  }
}
