import 'package:flutterapp/reward/model/bought_reward_model.dart';
import 'package:flutterapp/util/dao/abstract_dao.dart';
import 'package:flutterapp/util/data.dart';
import 'package:sqflite_common/sqlite_api.dart';

class BoughtRewardDao extends AbstractDao<BoughtReward> {
  BoughtRewardDao(Future<Database> db) : super(db, 'BOUGHT_REWARD');

  Future<List<BoughtReward>> list(int limit, int offset) async {
    return super.loadAll(limit: limit, offset: offset, orderBy: 'boughtAt DESC');
  }

  @override
  BoughtReward fromMap(Map<String, dynamic> values) {
    final result = BoughtReward();
    result.id = values['id'];
    result.name = values['name'];
    result.cost = values['cost'];
    result.boughtAt = ParserUtil.parseDate(values['boughtAt']);
    return result;
  }

  @override
  Map<String, dynamic> toMap(BoughtReward value) {
    return {
      'id': value.id,
      'name': value.name,
      'cost': value.cost,
      'boughtAt': ParserUtil.dateToNumber(value.boughtAt),
    };
  }
}