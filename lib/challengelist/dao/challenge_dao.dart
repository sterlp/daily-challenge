import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/log/logger.dart';
import 'package:flutterapp/util/dao/abstract_dao.dart';
import 'package:flutterapp/util/data.dart';
import 'package:flutterapp/util/date.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';

class ChallengeDao extends AbstractDao<Challenge> {
  static Logger _log = LoggerFactory.get<ChallengeDao>();
  ChallengeDao(Future<Database> db) : super(db, 'CHALLENGE');

  Future<int> sumByStatus(ChallengeStatus status) async {
    final Database db = await dbExecutor;

    var r = await db.rawQuery("SELECT SUM(reward) as rewardSum FROM " + tableName + " WHERE status = ?", [ParserUtil.valueOfEnum(status)]);
    if (r == null || r.length == 0) return 0;
    else return r[0]['rewardSum'] ?? 0;
  }


  Future<Iterable<String>> loadNamesByPattern(String pattern, {int limit = 5}) async {
    var db = await dbExecutor;
    var list = await db.rawQuery('SELECT DISTINCT name FROM $tableName WHERE status <> "open" AND name <> ? AND name like ? ORDER BY NAME',
        [pattern, pattern + "%"]);
    return list.map((e) => e['name']);
  }

  /// Sets the given challenges to fail and returns their total reward.
  Future<int> fail(List<Challenge> values) async {
    int result = 0;
    final DateTime now = DateTimeUtil.midnight(DateTime.now());
    for(Challenge c in values) {
      c.status = ChallengeStatus.failed;
      c.doneAt = now;
      result += c.reward;
      await update(c);
    }
    return result;
  }
  Future<List<Challenge>> loadOverDue() async {
    var now = DateTimeUtil.clearTime(DateTime.now());
    List<Challenge> results = await loadAll(
        where: "dueAt < ? AND status = 'open'",
        whereArgs: [now.millisecondsSinceEpoch],
        orderBy: 'dueAt ASC, createdAt DESC');

    _log.debug('loadOverDue ${results.length}');
    return results;
  }
  Future<List<Challenge>> loadByDate(DateTime dateTime) async {
    var from = DateTime(dateTime.year, dateTime.month, dateTime.day);
    var to = DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);

    List<Challenge> results = await loadAll(
        where: "(dueAt >= ? AND dueAt <= ?) OR (doneAt >= ? AND doneAt <= ?)",
        whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch, from.millisecondsSinceEpoch, to.millisecondsSinceEpoch],
        orderBy: 'dueAt ASC, createdAt DESC');
    _log.debug('loadByDate from $from to $to results ${results.length}');
    return results;
  }
  Future<int> countFinished() async {
    final Database db = await dbExecutor;

    final r = await db.rawQuery("SELECT COUNT(*) as result FROM $tableName WHERE status <> 'open'");
    return Sqflite.firstIntValue(r) ?? 0;
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