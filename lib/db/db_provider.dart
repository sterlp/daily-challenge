import 'dart:async';
import 'package:challengeapp/container/app_context_model.dart';
import 'package:challengeapp/db/update/db_v1.dart';
import 'package:challengeapp/db/update/db_v2.dart';
import 'package:challengeapp/log/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbProvider with Closeable {
  static final Logger _log = LoggerFactory.get<DbProvider>();
  Completer<Database> _completer = Completer();
  Future<Database> get db => _completer.future;

  DbProvider() {
    _init(null);
  }
  DbProvider.withDb(Future<Database> database) {
    _init(database);
  }

  Future<void> _init(Future<Database> _db) async {
    try {
      _log.startSync('init DB');
      Database database;
      if (_db == null) {
        // await deleteDatabase(join(await getDatabasesPath(), 'challenge.db'));
        database = await openDatabase(join(await getDatabasesPath(), 'challenge.db'), version: 2, onUpgrade: _createDB);
      } else {
        database = await _db;
        await _createDB(database, 0, 99);
      }
      _completer.complete(database);
    } catch (e) {
      _completer.completeError(e);
      _log.error('Failed to load DB', e);
    } finally {
      _log.finishSync();
    }
  }

  Future<int> _createDB(Database db, int oldVersion, int newVersion) async {
    _log.info('_createDB with from version $oldVersion to $newVersion');
    oldVersion = await DbV1().execute(oldVersion, db);
    oldVersion = await DbV2().execute(oldVersion, db);
    return oldVersion;
  }

  @override
  Future<void> close() async {
    var close = await (await db).close();
    _log.debug('DB closed');
    return close;
  }
}
