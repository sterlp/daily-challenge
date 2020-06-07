import 'dart:developer';

import 'package:flutterapp/challengelist/models/challengeModel.dart';
import 'package:flutterapp/util/dao/abstractDao.dart';
import 'package:flutterapp/util/data.dart';
import 'package:flutterapp/util/date.dart';
import 'package:sqflite_common/sqlite_api.dart';

class ChallengeDao extends AbstractDao<Challenge> {
  ChallengeDao(Future<Database> db) : super(db, 'CHALLENGE');

  Future<int> sumByStatus(ChallengeStatus status) async {
    final Database db = await dbExecutor;

    var r = await db.rawQuery("SELECT SUM(reward) as rewardSum FROM " + tableName + " WHERE status = ?", [ParserUtil.valueOfEnum(status)]);
    if (r == null || r.length == 0) return 0;
    else return r[0]['rewardSum'] ?? 0;
  }

  /// Sets the given challenges to fail and returns their total reward.
  Future<int> fail(List<Challenge> values) async {
    final Database db = await dbExecutor;
    return db.transaction((trx) async {
      int result = 0;
      for(Challenge c in values) {
        c.status = ChallengeStatus.failed;
        result += c.reward;
        await update(c);
      }
      return result;
    });
  }
  Future<List<Challenge>> loadOverDue() async {
    var now = DateTimeUtil.clearTime(DateTime.now());
    List<Challenge> results = await loadAll(
        where: "dueAt < ? AND status = 'open'",
        whereArgs: [now.millisecondsSinceEpoch],
        orderBy: 'dueAt ASC, createdAt DESC');

    log('loadOverDue ${results.length}');
    return results;
  }
  Future<List<Challenge>> loadByDate(DateTime dateTime) async {
    var from = DateTime(dateTime.year, dateTime.month, dateTime.day);
    var to = DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);

    List<Challenge> results = await loadAll(
        where: "dueAt >= ? AND dueAt <= ?",
        whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch],
        orderBy: 'dueAt ASC, createdAt DESC');
    log('loadByDate from $from to $to results ${results.length}');
    return results;
  }

  @override
  Challenge fromMap(Map<String, dynamic> values) {
    final result = Challenge();
    result.id = values['id'];
    result.name = values['name'];
    result.reward = values['reward'];
    result.status = ParserUtil.parseEnumStringWithDefault(ChallengeStatus.values, values['status'], ChallengeStatus.open);
    result.createdAt = ParserUtil.parseDate(values['createdAt']);
    result.doneAt = ParserUtil.parseDate(values['doneAt']);
    result.dueAt = ParserUtil.parseDate(values['dueAt']);
    result.latestAt = ParserUtil.parseDate(values['latestAt']);
    return result;
  }

  @override
  Map<String, dynamic> toMap(Challenge value) {
    return {
      'id': value.id,
      'name': value.name,
      'reward': value.reward,
      'status': ParserUtil.valueOfEnum(value.status),
      'createdAt': ParserUtil.dateToNumber(value.createdAt),
      'dueAt': ParserUtil.dateToNumber(value.dueAt),
      'doneAt': ParserUtil.dateToNumber(value.doneAt),
      'latestAt': ParserUtil.dateToNumber(value.latestAt),
    };
  }
}