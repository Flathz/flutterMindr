// Create a Form widget.
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/db_helper.dart';

import 'models/Note.dart';

class NoteDetail extends StatefulWidget {
  @override
  NoteDetailState createState() => NoteDetailState();
}

class NoteDetailState extends State<NoteDetail> {
  DBHelper dbHelper;
  Note note;
  bool _isEditingText = false;
  TextEditingController _editingTitleController;
  TextEditingController _editingContentController;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
  }

  deleteNote(id) {
    dbHelper.delete(id);
  }

  Note getNote(id) {
    Future<Note> result = dbHelper.getNote(id);
    result.then((value) {
      setState(() {
        note = value;
      });
    });
    return note;
  }

  @override
  Widget build(BuildContext context) {
    final noteId = ModalRoute.of(context).settings.arguments;
    note = getNote(noteId);

    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            appBar: AppBar(title: const Text("Detail")),
            body: Stack(
              children: <Widget>[
                ListView(
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                    Container(
                      height: 40,
                    ),
                    AnimatedOpacity(
                      duration: Duration(milliseconds: 500),
                      opacity: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24, top: 80),
                        child: Text(
                          note == null ? "" : note.date,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24.0, top: 36, bottom: 24, right: 24),
                      child: _editNote(note == null ? "" : note.content,
                          _editingContentController, false),
                    )
                  ],
                ),
                ClipRect(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        height: 100,
                        color: Theme.of(context).canvasColor.withOpacity(0.3),
                        child: SafeArea(
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 24.0,
                                  right: 24.0,
                                  top: 40.0,
                                  bottom: 16),
                              child: Row(
                                children: <Widget>[
                                  AnimatedOpacity(
                                    opacity: 1,
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.easeIn,
                                    child: SizedBox(
                                        width: 250.0,
                                        child: _editNote(
                                            note == null ? "" : note.title,
                                            _editingTitleController,
                                            true)),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline),
                                    onPressed: () {
                                      return showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text("Delete ?"),
                                          content: Text(
                                              "Do you want to delete this note ?"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                deleteNote(noteId);
                                                Navigator.of(ctx).pop(true);
                                                Navigator.of(context).pop(true);
                                              },
                                              child: Text("Yes"),
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(ctx).pop(true);
                                                },
                                                child: Text("No"))
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => {
                                      setState(() {
                                        _editingTitleController =
                                            TextEditingController(
                                                text: note.title);
                                        _editingContentController =
                                            TextEditingController(
                                                text: note.content);
                                        _isEditingText = true;
                                      })
                                    },
                                  ),
                                ],
                              )),
                        ),
                      )),
                )
              ],
            ),
            floatingActionButton: displayButton()));
  }

  Widget _editNote(text, controller, isTitle) {
    if (_isEditingText)
      return TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
        ),
        controller: controller,
        keyboardType: isTitle ? TextInputType.text : TextInputType.multiline,
        maxLines: null,
        style: isTitle
            ? TextStyle(
                fontSize: 32.0,
                color: Colors.black,
                fontFamily: 'ZillaSlab',
                fontWeight: FontWeight.w500,
              )
            : TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      );
    return Container(
        padding: EdgeInsets.all(0),
        child: Text(
          text,
          overflow: !isTitle ? TextOverflow.visible : TextOverflow.ellipsis,
          softWrap: true,
          style: isTitle
              ? TextStyle(
                  fontSize: 32.0,
                  color: Colors.black,
                  fontFamily: 'ZillaSlab',
                  fontWeight: FontWeight.w500,
                )
              : TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ));
  }

  Widget displayButton() {
    if (_isEditingText &&
        (_editingTitleController.text != note.title ||
            _editingContentController.text != note.content)) {
      return FloatingActionButton(
        onPressed: () {
          dbHelper.update(Note(note.id, _editingTitleController.text,
              _editingContentController.text, note.date));
          _isEditingText = false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Note updated !'),
            duration: Duration(milliseconds: 1000),
          ));
        },
        child: const Icon(Icons.done),
        backgroundColor: Colors.blue,
      );
    } else {
      return null;
    }
  }

  Future<bool> _onBackPressed() {
    if (_isEditingText &&
        (_editingTitleController.text != note.title ||
            _editingContentController.text != note.content)) {
      return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text("Unsaved modifications"),
              content: Text("Do you want to save your modifications ?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    setState(() {
                      dbHelper.update(Note(
                          note.id,
                          _editingTitleController.text,
                          _editingContentController.text,
                          note.date));
                      _isEditingText = false;
                    });
                  },
                  child: Text("Yes"),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text("No"))
              ],
            ),
          ) ??
          false;
    } else {
      Navigator.of(context).pop(true);
      return null;
    }
  }
}
