import 'dart:async';
import 'package:flutterapp/container/containerModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer';

class DbProvider with Closeable {
  Future<Database> db;
  DbProvider() {
    db = _init(null);
  }
  DbProvider.withDb(Future<Database> database) {
    db = _init(database);
  }

  Future<Database> _init(Future<Database> _db) async {
    if (_db == null) {
      // await deleteDatabase(join(await getDatabasesPath(), 'challenge.db'));
      return openDatabase(join(await getDatabasesPath(), 'challenge.db'), version: 1, onUpgrade: createDB);
    } else {
      await createDB(await _db, 0, 99);
      return _db;
    }
  }

  ///
  /// int id;
  //  String name;
  //  int reward;
  //  DateTime createdAt;
  //  DateTime doneAt;
  //  bool done;
  createDB(Database db, int oldVersion, int newVersion) async {
    log('_createDB with from version $oldVersion to $newVersion');

    if (oldVersion == 0) {
      db.execute('''CREATE TABLE IF NOT EXISTS CHALLENGE (
          id integer PRIMARY KEY AUTOINCREMENT,
          name text NOT NULL,
          status varchar(10) DEFAULT 'open',
          reward integer DEFAULT 0,
          createdAt integer NOT NULL,
          doneAt integer,
          dueAt integer NOT NULL,
          latestAt integer
        );
        CREATE INDEX IF NOT EXISTS IDX_CHALLENGE_CREATE_AT ON CHALLENGE(createdAt);
        CREATE INDEX IF NOT EXISTS IDX_CHALLENGE_DONE ON CHALLENGE(dueAt);
        CREATE INDEX IF NOT EXISTS IDX_CHALLENGE_DONE ON CHALLENGE(satus);
      ''');
      ++oldVersion;
    }
  }

  @override
  void close() {
    log('DB closed', name: this.toString());
    db.then((value) => value.close());
    db = null;
  }
}