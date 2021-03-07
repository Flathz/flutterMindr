import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/db_helper.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:keyboard_visibility/keyboard_visibility.dart';

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
  String init;
  List<Note> allNotes = [];
  bool _isEditingText = false;
  TextEditingController _editingController;
  bool keyboardOpen = false;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    _speech = stt.SpeechToText();
    _editingController = TextEditingController(text: _text);
    init = _text;

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        setState(() {
          keyboardOpen = visible;
        });
      },
    );
  }

  @override
  void dispose() {
    _editingController.dispose();
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
    var note = Note(null, title, _text,
        DateFormat('dd-MM-yyyy – kk:mm').format(DateTime.now()));
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
                children: _showButtons())),
        body: new GestureDetector(
          onTap: () {
            setState(() {
              if (!FocusScope.of(context).hasPrimaryFocus)
                FocusScope.of(context).unfocus();
              _isEditingText = false;
            });
          },
          child: SingleChildScrollView(
            reverse: true,
            child: Container(
                padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
                child: _editTitleTextField()),
          ),
        ));
  }

  Widget _editTitleTextField() {
    if (_isEditingText)
      return Center(
        child: TextField(
          onChanged: (newValue) {
            setState(() {
              _text = newValue;
            });
          },
          autofocus: true,
          controller: _editingController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          style: TextStyle(
            fontSize: 32.0,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    return InkWell(
        onTap: () {
          setState(() {
            _isEditingText = true;
            if (_text == init) {
              _text = "";
              _editingController = TextEditingController(text: _text);
            }
          });
        },
        child: Text(
          _text,
          style: TextStyle(
            fontSize: 32.0,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ));
  }

  List<Widget> _showButtons() {
    return !keyboardOpen
        ? <Widget>[
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
                  _text = init;
                });
              },
              child: Icon(Icons.add),
            )
          ]
        : <Widget>[
            FloatingActionButton(
              onPressed: () {
                addNote();
                setState(() {
                  _text = init;
                });
              },
              child: Icon(Icons.add),
            )
          ];
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
            _editingController = TextEditingController(text: _text);
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}
