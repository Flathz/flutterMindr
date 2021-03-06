import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/db_helper.dart';
import 'package:intl/intl.dart';
import 'models/Note.dart';

class AddNoteWidget extends StatefulWidget {
  AddNoteWidget({Key key}) : super(key: key);

  @override
  _AddNoteWidget createState() => _AddNoteWidget();
}

class _AddNoteWidget extends State<AddNoteWidget> {
  final _formKey = GlobalKey<FormState>();
  DBHelper dbHelper;
  final content = TextEditingController();
  List<Note> allNotes = [];

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    content.dispose();
    super.dispose();
  }

  addNote() {
    dbHelper.getNotes().then((value) {
      setState(() {
        allNotes = value.toList();
      });
    });
    int length = allNotes.length + 1;
    var title = "Note " + length.toString();
    var note = Note(null, title, content.text,
        DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()));
    dbHelper.add(note);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Note ajouté !'),
      duration: Duration(milliseconds: 500),
    ));
  }

  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: 200, left: 30, right: 30),
              child: TextFormField(
                controller: content,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
                child: FloatingActionButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  addNote();
                  content.text = "";
                }
              },
              child: Icon(Icons.add),
            )),
          ),
        ],
      ),
    );
  }
}
