import 'dart:async';
import 'package:flutterapp/container/app_context_model.dart';
import 'package:flutterapp/db/update/db_v1.dart';
import 'package:flutterapp/db/update/db_v2.dart';
import 'package:flutterapp/log/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbProvider with Closeable {
  static final Logger _log = LoggerFactory.get<DbProvider>();

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
      return openDatabase(join(await getDatabasesPath(), 'challenge.db'), version: 2, onUpgrade: createDB);
    } else {
      await createDB(await _db, 0, 99);
      return _db;
    }
  }

  createDB(Database db, int oldVersion, int newVersion) async {
    _log.info('_createDB with from version $oldVersion to $newVersion');
    oldVersion = DbV1().execute(oldVersion, db);
    oldVersion = DbV2().execute(oldVersion, db);
  }

  @override
  Future<void> close() async {
    var close = (await db).close();
    _log.debug('DB closed');
    db = null;
    return close;
  }
}
