import 'package:sqflite/sqflite.dart' as sqlflite;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';


class DBProvider {
  static sqlflite.Database _database;

  static final DBProvider instance = DBProvider._();

  //constructor
  DBProvider._();

  Future<sqlflite.Database> get database async {
    if (_database != null) {
      if (!_database.isOpen) {
        assert(!_database.isOpen, 'Db is closed');
        DBProvider._database = await open();
      }

      return _database;
    }

    DBProvider._database = await open();
    return DBProvider._database;
  }

  close() async {
    print('DATABASE. close');
    if (_database != null) {
      await _database.close();
    }
  }

  open() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'TodoList.db');

    print('DATABASE. open');

    try {
      sqlflite.Database db = await sqlflite.openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onOpen: _onOpen,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
        onDowngrade: _onDowngrade
      );

      return db;
    } catch (err) {
      print('-------create db exception------');
      print(err);
      return null;
    }
  }

  _onUpgrade (sqlflite.Database db, int oldVersion, int newVersion) async {
    print('DATABASE. onUpgrade');

    if (newVersion > oldVersion) {
      print('begin upgrade database....newV: $newVersion, oldV: $oldVersion');

      await db.execute(
        """
        
        """
      );
    }
  }

  _onCreate (sqlflite.Database db, int version) async {
    print('DATABASE. onCreate');

    //project
    await db.execute(
      """
      create table todo_list (
        todo_list_id integer primary key autoincrement,
        name text not null,
        is_finished integer default 0,
        guid text default (hex(randomblob(16)))
      );
      """
    );

    await db.execute(
      """
      create index todo_list_is_finished_idx on todo_list (is_finished);
      """
    );
  }

  _onOpen (sqlflite.Database db) async {
    print('DATABASE. onOpen');
  }

  _onDowngrade (sqlflite.Database db, int oldVersion, int newVersion) async {
    print('DATABASE. onDowngrade');
  }

  _onConfigure (sqlflite.Database db) async {
    print('DATABASE. onConfigure');
  }
}