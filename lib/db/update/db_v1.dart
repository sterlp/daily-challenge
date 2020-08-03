import 'package:challengeapp/db/update/db_update.dart';
import 'package:sqflite_common/sqlite_api.dart';

class DbV1 extends DbUpdate {
  DbV1() : super(1);

  @override
  Future<void> update(Database db) {
    return db.execute('''CREATE TABLE IF NOT EXISTS CHALLENGE (
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
        CREATE INDEX IF NOT EXISTS IDX_CHALLENGE_DUE_AT ON CHALLENGE(dueAt);
        CREATE INDEX IF NOT EXISTS IDX_CHALLENGE_DONE_AT ON CHALLENGE(doneAt);
        CREATE INDEX IF NOT EXISTS IDX_CHALLENGE_DONE ON CHALLENGE(status);
      ''');
  }
}