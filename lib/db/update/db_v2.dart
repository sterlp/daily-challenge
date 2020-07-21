import 'package:flutterapp/db/update/db_update.dart';
import 'package:sqflite_common/sqlite_api.dart';

class DbV2 extends DbUpdate {
  DbV2() : super(2);

  @override
  void update(Database db) {
    db.execute('''CREATE TABLE IF NOT EXISTS REWARD (
          id integer PRIMARY KEY AUTOINCREMENT,
          name varchar(50) NOT NULL,
          cost integer
        );
        CREATE INDEX IF NOT EXISTS IDX_REWARD_NAME ON REWARD(name);
        CREATE INDEX IF NOT EXISTS IDX_REWARD_COST ON REWARD(cost);
      ''');

    db.execute('''CREATE TABLE IF NOT EXISTS BOUGHT_REWARD (
          id integer PRIMARY KEY AUTOINCREMENT,
          name varchar(50) NOT NULL,
          cost integer,
          boughtAt integer
        );
        CREATE INDEX IF NOT EXISTS IDX_BOUGHT_REWARD_AT ON BOUGHT_REWARD(boughtAt);
       ''');
  }
}