import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'models/Note.dart';

class DBHelper {
  static Database _db;
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'notes.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db
        .execute('CREATE TABLE note (id INTEGER PRIMARY KEY, title TEXT, content TEXT)');
  }

  Future<Note> add(Note note) async {
    var dbClient = await db;
    note.id = await dbClient.insert('note', note.toMap());
    return note;
  }

  Future<List<Note>> getStudents() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query('note', columns: ['id', 'title', 'content']);
    List<Note> notes = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        notes.add(Note.fromMap(maps[i]));
      }
    }
    return notes;
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(
      'note',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> update(Note note) async {
    var dbClient = await db;
    return await dbClient.update(
      'note',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}