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

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
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

    return Scaffold(
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
                      note.date,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24.0, top: 36, bottom: 24, right: 24),
                  child: Text(
                    note.content,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
            ClipRect(
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: 80,
                    color: Theme.of(context).canvasColor.withOpacity(0.3),
                    child: SafeArea(
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 24.0, right: 24.0, top: 40.0, bottom: 16),
                          child: Row(
                            children: <Widget>[
                              AnimatedOpacity(
                                opacity: 1,
                                duration: Duration(milliseconds: 200),
                                curve: Curves.easeIn,
                                child: Text(
                                  note.title,
                                  style: TextStyle(
                                    fontFamily: 'ZillaSlab',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 36,
                                  ),
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.delete_outline),
                                onPressed: () => {},
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => {},
                              ),
                            ],
                          )),
                    ),
                  )),
            )
          ],
        ));
  }
}
