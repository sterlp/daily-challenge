import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/common/dao/abstract_dao.dart';
import 'package:challengeapp/log/logger.dart';
import 'package:challengeapp/util/data.dart';
import 'package:challengeapp/util/date.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';

class ChallengeDao extends AbstractDao<Challenge> {
  static final Logger _log = LoggerFactory.get<ChallengeDao>();

  ChallengeDao(Future<Database> db) : super(db, 'CHALLENGE');

  Future<int> sumByStatus(ChallengeStatus status) async {
    final db = await dbExecutor;

    final r = await db.rawQuery("SELECT SUM(reward) as rewardSum FROM $tableName WHERE status = ?", [ParserUtil.valueOfEnum(status)]);
    if (r == null || r.isEmpty) return 0;
    else return r[0]['rewardSum'] as int ?? 0;
  }


  Future<Iterable<String>> loadNamesByPattern(String pattern, {int limit = 5}) async {
    final db = await dbExecutor;
    final list = await db.rawQuery('SELECT DISTINCT name FROM $tableName WHERE status <> "open" AND name <> ? AND name like ? ORDER BY NAME',
        [pattern, pattern + "%"]);
    return list.map((e) => e['name'] as String);
  }

  /// Sets the given challenges to fail and returns their total reward.
  Future<int> fail(List<Challenge> values) async {
    int result = 0;
    final DateTime now = DateTimeUtil.midnight(DateTime.now());
    for(final c in values) {
      c.status = ChallengeStatus.failed;
      c.doneAt = c.latestAt == null ? now : DateTimeUtil.midnight(c.latestAt);
      result += c.reward;
      await update(c);
    }
    return result;
  }

  Future<List<Challenge>> loadOverDue() async {
    final now = DateTimeUtil.clearTime(DateTime.now());
    final results = await loadAll(
        where: "dueAt < ? AND status = 'open'",
        whereArgs: [now.millisecondsSinceEpoch],
        orderBy: 'latestAt ASC, dueAt ASC, createdAt DESC');

    _log.debug('loadOverDue ${results.length}');
    return results;
  }

  Future<List<Challenge>> loadOpenByDueAt(DateTime dateTime) async {
    final from = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final to = DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);

    final result = await loadAll(
        where: "(dueAt >= ? AND dueAt <= ?) AND status = 'open'",
        whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch],
        orderBy: 'dueAt ASC, latestAt ASC, createdAt DESC');

    _log.debug('loadOpenByDueAt from $from to $to results ${result.length}');

    return result;
  }

  Future<List<Challenge>> loadAllOpenUntil(DateTime dateTime) async {
    final to = DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);

    final result = await loadAll(
        where: "dueAt <= ? AND status = 'open'",
        whereArgs: [to.millisecondsSinceEpoch],
        orderBy: 'latestAt ASC, dueAt ASC, createdAt DESC');

    _log.debug('loadAllOpenUntil from $dateTime results ${result.length}');

    return result;
  }

  Future<List<Challenge>> loadDoneByDoneAt(DateTime dateTime) async {
    final from = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final to = DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);

    final result = await loadAll(
        where: "(doneAt >= ? AND doneAt <= ?) AND status <> 'open'",
        whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch],
        orderBy: 'doneAt DESC');

    _log.debug('loadByDoneAt from $from to $to results ${result.length}');

    return result;
  }

  Future<int> countFinished() async {
    final Database db = await dbExecutor as Database;

    final r = await db.rawQuery("SELECT COUNT(*) as result FROM $tableName WHERE status <> 'open'");
    return Sqflite.firstIntValue(r) ?? 0;
  }

  @override
  Challenge fromMap(Map<String, dynamic> values) {
    final result = Challenge();
    result.id = values['id'] as int;
    result.name = values['name'] as String;
    result.reward = values['reward'] as int;
    result.status = ParserUtil.parseEnumStringWithDefault(
        ChallengeStatus.values, values['status'] as String, ChallengeStatus.open);
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