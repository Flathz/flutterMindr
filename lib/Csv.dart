import 'dart:io';

import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'models/Note.dart';
import 'package:flutter_app/db_helper.dart';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';

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

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    String csv = const ListToCsvConverter().convert(csvData);
    print(csv);
    final String dir = (await DownloadsPathProvider.downloadsDirectory).path;
    final String path = '$dir/notes.csv';
    final File file = File(path);
    await file.writeAsString(csv);
    return true;
  }

  Future<bool> importCsv() async {
    dbHelper = DBHelper();
    final String dir = (await DownloadsPathProvider.downloadsDirectory).path;
    final String path = '$dir/notes.csv';
    if (await File(path).exists()) {
      final File file = File(path);
      String contents = await file.readAsString();
      List<List<dynamic>> csvTable = CsvToListConverter().convert(contents);
      print(csvTable);
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
