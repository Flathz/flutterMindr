// Create a Form widget.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoteDetail extends StatefulWidget {
  @override
  NoteDetailState createState() => NoteDetailState();
}

// Create a corresponding State class.
// This class holds data related to the form.
class NoteDetailState extends State<NoteDetail> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Text("salut");
  }
}
