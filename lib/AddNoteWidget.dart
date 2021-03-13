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
  String _text =
      'Press the button and start speaking or click on the text to write something.';
  String init;
  String _tempText;
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
    if (_text == init || _text == "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Say or type something to add it to the note.'),
        duration: Duration(milliseconds: 2000),
      ));
    } else {
      var title = "Untitled note";
      var note = Note(null, title, _text,
          DateFormat('dd-MM-yyyy – kk:mm').format(DateTime.now()));
      dbHelper.add(note);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Note added !'),
        duration: Duration(milliseconds: 1000),
      ));
    }
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
                FocusScope.of(context).requestFocus(FocusNode());
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
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          autofocus: true,
          controller: _editingController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          style: TextStyle(
            fontSize: 32.0,
            color: Colors.black,
            fontFamily: 'ZillaSlab',
            fontWeight: FontWeight.w500,
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
            fontFamily: 'ZillaSlab',
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  List<Widget> _showButtons() {
    return !keyboardOpen
        ? <Widget>[
            FloatingActionButton(
              onPressed: () {
                cancelNote();
              },
              child: Icon(Icons.close),
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
                  FocusScope.of(context).requestFocus(FocusNode());
                  _isEditingText = false;
                  _text = init;
                  _editingController = TextEditingController(text: _text);
                });
              },
              child: Icon(Icons.add),
            )
          ]
        : <Widget>[
            FloatingActionButton(
              onPressed: () {
                cancelNote();
              },
              child: Icon(Icons.close),
            ),
            FloatingActionButton(
              onPressed: () {
                addNote();
                setState(() {
                  FocusScope.of(context).requestFocus(FocusNode());
                  _isEditingText = false;
                  _text = init;
                  _editingController = TextEditingController(text: _text);
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
        _tempText = _text == init ? "" : _text + " ";
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = _tempText + val.recognizedWords;
            _editingController = TextEditingController(text: _text);
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  cancelNote() {
    if (_text == init) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Your note is already empty'),
        duration: Duration(milliseconds: 1000),
      ));
    } else {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Delete ?"),
          content: Text("Do you want to delete your text ?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  FocusScope.of(context).requestFocus(FocusNode());
                  _isEditingText = false;
                  _text = init;
                  _editingController = TextEditingController(text: _text);
                });
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
    }
  }
}
