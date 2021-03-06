import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/db_helper.dart';
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

   Widget build(BuildContext context) {
        // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: content,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  var note = Note(null, "test", content.text);
                  dbHelper.add(note);
                }
              },
              child: Text('Add'),
            ),
          ),
        ],
      ),
    );
  }
}