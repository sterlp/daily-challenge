import 'package:flutterapp/log/logger.dart';
import 'package:sqflite/sqflite.dart';

abstract class DbUpdate {
  Logger log;
  final int version;

  DbUpdate(this.version) {
    log = LoggerFactory.getWithName(this.runtimeType.toString());
  }

  Future<int> execute(int currentVersion, Database db) async {
    if (currentVersion + 1 == version) {
      log.info('update DB from $currentVersion -> $version.');
      await update(db);
      return version;
    }
    return currentVersion;
  }
  Future<void> update(Database db);
}