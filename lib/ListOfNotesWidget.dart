import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/NoteDetail.dart';
import 'models/Note.dart';
import 'package:flutter_app/db_helper.dart';
import 'package:flutter_app/Csv.dart';

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
  Csv csv = null;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    dbHelper.getNotes().then((value) {
      setState(() {
        _items = value.reversed.toList();
        csv = Csv(_items);
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

    return RefreshIndicator(
        onRefresh: () async {
          refreshList();
          return await Future.delayed(Duration(seconds: 1));
        },
        displacement: 100,
        child: Column(children: [
          Row(children: [
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      top: 20,
                      right: 5,
                      bottom: 20,
                    ),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: new BorderRadius.circular(25.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 3.0,
                                offset: const Offset(0, 3),
                              )
                            ]),
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            contentPadding: EdgeInsets.all(15),
                            hintText: 'Search through notes',
                            fillColor: Colors.white,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                          onChanged: (string) {
                            setState(() {
                              _filterItems = _items.where((element) {
                                var temp =
                                    string.split(" ").where((e) => e != "");
                                bool isIn = temp.every((e) => ((element.content
                                            .toLowerCase()
                                            .contains(e) ||
                                        element.title
                                            .toLowerCase()
                                            .contains(e)) &&
                                    e != ""));

                                return isIn;
                              }).toList();
                            });
                          },
                        )))),
            Padding(
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 10,
                  bottom: 0,
                ),
                child: IconButton(
                    icon: Icon(
                      Icons.more_vert,
                    ),
                    onPressed: () => _showPopupMenu()))
          ]),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: <Widget>[
                if (_filterItems.length == 0)
                  Container(
                      height: 500,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(20),
                              child: Icon(
                                Icons.no_sim_outlined,
                                size: 100,
                              )),
                          Text(
                            "You will see all your notes here",
                            style: TextStyle(fontSize: 20.0),
                          )
                        ],
                      )),
                for (int index = 0; index < _filterItems.length; index++)
                  Container(
                    height: 100,
                    child: Card(
                        key: Key('$index'),
                        child: ListTile(
                          tileColor: _filterItems[index].isOdd
                              ? oddItemColor
                              : evenItemColor,
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoteDetail(),
                                  settings: RouteSettings(
                                    arguments: _filterItems[index].id,
                                  ),
                                ));
                            refreshList();
                          },
                          leading: Icon(Icons.note_outlined),
                          trailing: GestureDetector(
                              onTap: () {
                                return showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text("Delete ?"),
                                    content: Text(
                                        "Do you want to delete this note ?"),
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
                          title: Text(truncateWithEllipsis(
                              30, _filterItems[index].title)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(
                              left: 0,
                              top: 15,
                              right: 0,
                              bottom: 0,
                            ),
                            child: Text(truncateWithEllipsis(
                                35, _filterItems[index].content)),
                          ),
                        )),
                  )
              ]))
        ]));
  }

  _showPopupMenu() {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(20.0, 120.0, 0.0, 0.0),
      items: [
        PopupMenuItem<String>(
            child: const Text('Export notes to .csv'), value: '1'),
        PopupMenuItem<String>(
            child: const Text('Import note from .csv'), value: '2'),
      ],
      elevation: 8.0,
    ).then<void>((String itemSelected) {
      if (itemSelected == null) return;

      if (itemSelected == "1") {
        csv.getCsv().then((value) {
          if (value) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Notes exported to your download folder'),
              duration: Duration(milliseconds: 2000),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error during export'),
              duration: Duration(milliseconds: 2000),
            ));
          }
        });
      } else {
        csv.importCsv().then((value) {
          if (value) {
            refreshList();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Notes imported from your download folder'),
              duration: Duration(milliseconds: 2000),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Check if you have .csv file in your download folder'),
              duration: Duration(milliseconds: 2000),
            ));
          }
        });
      }
    });
  }
}
