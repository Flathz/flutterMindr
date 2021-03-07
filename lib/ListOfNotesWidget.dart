import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/NoteDetail.dart';
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
        _items = value.reversed.toList();
        _filterItems = _items;
      });
    });
  }

  refreshList() {
    dbHelper.getNotes().then((value) {
      setState(() {
        _items = value.reversed.toList();
        _filterItems = _items;
      });
    });
  }

  deleteNote(id) {
    dbHelper.delete(id);
    refreshList();
  }

  String truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff)
        ? myString
        : '${myString.substring(0, cutoff)}...';
  }

  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final oddItemColor = colorScheme.primary.withOpacity(0.05);
    final evenItemColor = colorScheme.primary.withOpacity(0.15);

    return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(
                left: 10,
                top: 20,
                right: 10,
                bottom: 20,
              ),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5.0,
                          offset: const Offset(0, 5),
                        )
                      ]),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.all(15),
                      hintText: 'Search through note',
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
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
                  ))),
          for (int index = 0; index < _filterItems.length; index++)
            Container(
                height: 100,
                child: Card(
                  key: Key('$index'),
                  child: ListTile(
                    tileColor: _filterItems[index].isOdd
                        ? oddItemColor
                        : evenItemColor,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteDetail(),
                            settings: RouteSettings(
                              arguments: _filterItems[index].id,
                            ),
                          ));
                    },
                    leading: Icon(Icons.notes_rounded),
                    trailing: GestureDetector(
                        onTap: () {
                          return showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text("Delete ?"),
                              content:
                                  Text("Do you want to delete this note ?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    deleteNote(_filterItems[index].id);
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text("Yes"),
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Text("No"))
                              ],
                            ),
                          );
                        },
                        child: Icon(Icons.delete)),
                    title: Text(
                        truncateWithEllipsis(50, _filterItems[index].title)),
                    subtitle: Text(
                        truncateWithEllipsis(50, _filterItems[index].content)),
                  ),
                )),
        ]);
  }
}
