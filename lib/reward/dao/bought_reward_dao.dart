import 'package:challengeapp/reward/model/bought_reward_model.dart';
import 'package:challengeapp/common/dao/abstract_dao.dart';
import 'package:challengeapp/util/data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';

class BoughtRewardDao extends AbstractDao<BoughtReward> {
  BoughtRewardDao(Future<Database> db) : super(db, 'BOUGHT_REWARD');

  Future<List<BoughtReward>> list(int limit, int offset) async {
    return super.loadAll(limit: limit, offset: offset, orderBy: 'boughtAt DESC');
  }

  Future<BoughtReward> getMostRecentByRewardId(int rewardId) async {
    var elements = await super.loadAll(where: 'rewardId = ?', whereArgs: [rewardId], orderBy: 'boughtAt DESC', limit: 1);
    if (elements.isEmpty) return Future.value(null);
    else return Future.value(elements[0]);
  }

  Future<int> sum() async {
    final Database db = await dbExecutor;
    final r = await db.rawQuery("SELECT SUM(cost) as rewardSum FROM " + tableName);
    return Sqflite.firstIntValue(r) ?? 0;
  }

  @override
  BoughtReward fromMap(Map<String, dynamic> values) {
    final result = BoughtReward();
    result.id = values['id'];
    result.name = values['name'];
    result.cost = values['cost'];
    result.boughtAt = ParserUtil.parseDate(values['boughtAt']);
    result.rewardId = values['rewardId'];
    return result;
  }

  @override
  Map<String, dynamic> toMap(BoughtReward value) {
    return {
      'id': value.id,
      'name': value.name,
      'cost': value.cost,
      'boughtAt': ParserUtil.dateToNumber(value.boughtAt),
      'rewardId': value.rewardId
    };
  }
}