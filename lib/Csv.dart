import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'models/Note.dart';
import 'package:flutter_app/db_helper.dart';
import 'package:csv/csv.dart';

class Csv {
  DBHelper dbHelper;
  List<Note> notes = [];

  Future<bool> getCsv() async {
    dbHelper = DBHelper();
    dbHelper.getNotes().then((value) {
      notes = value.reversed.toList();
    });

    List<List<String>> csvData = [
      <String>['Title', 'Content', 'Date'],
      ...notes.map((e) => [e.title, e.content, e.date])
    ];

    String csv = const ListToCsvConverter().convert(csvData);
    final String dir = (await getExternalStorageDirectory()).path;
    final String path = '$dir/notes.csv';
    final File file = File(path);
    await file.writeAsString(csv);
    return true;
  }

  Future<bool> importCsv() async {
    dbHelper = DBHelper();
    final String dir = (await getExternalStorageDirectory()).path;
    final String path = '$dir/notes.csv';
    if (await File(path).exists()) {
      final File file = File(path);
      String contents = await file.readAsString();
      List<List<dynamic>> csvTable = CsvToListConverter().convert(contents);
      for (var i = 1; i < csvTable.length; i++) {
        dbHelper
            .add(Note(null, csvTable[i][0], csvTable[i][1], csvTable[i][2]));
      }
      return true;
    } else {
      return false;
    }
  }
}
