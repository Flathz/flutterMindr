import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/db_helper.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'models/Note.dart';

class AddNoteWidget extends StatefulWidget {
  @override
  _AddNoteWidgetState createState() => _AddNoteWidgetState();
}

class _AddNoteWidgetState extends State<AddNoteWidget> {
  stt.SpeechToText _speech;
  bool _isListening = false;
  DBHelper dbHelper;
  String _text = 'Press the button and start speaking';

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    _speech = stt.SpeechToText();
  }

  addNote() {
    var count = 0;
    var title = "Note " + count.toString();
    var note = Note(null, title, _text,
        DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()));
    dbHelper.add(note);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Note ajouté !'),
      duration: Duration(milliseconds: 500),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
          padding: const EdgeInsets.all(40),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FloatingActionButton(
                  onPressed: () {},
                  child: Icon(Icons.keyboard),
                ),
                AvatarGlow(
                  animate: _isListening,
                  glowColor: Theme.of(context).primaryColor,
                  endRadius: 100.0,
                  duration: const Duration(milliseconds: 2000),
                  repeatPauseDuration: const Duration(milliseconds: 100),
                  repeat: true,
                  child: SizedBox(
                      width: 130,
                      height: 130,
                      child: FloatingActionButton(
                        onPressed: _listen,
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          size: 60,
                        ),
                      )),
                ),
                FloatingActionButton(
                  onPressed: () {
                    addNote();
                    setState(() {
                      _text = "";
                    });
                  },
                  child: Icon(Icons.add),
                )
              ])),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: Text(
            _text,
            style: TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}
