import 'package:challengeapp/common/dao/abstract_dao.dart';
import 'package:challengeapp/reward/model/reward_model.dart';
import 'package:sqflite_common/sqlite_api.dart';

class RewardDao extends AbstractDao<Reward> {
  RewardDao(Future<Database> db) : super(db, 'REWARD');

  Future<List<Reward>> list(int limit, int offset) {
    return super.loadAll(limit: limit, offset: offset, orderBy: 'COST ASC');
  }

  @override
  Reward fromMap(Map<String, dynamic> values) {
    final result = Reward();
    result.id = values['id'];
    result.name = values['name'];
    result.cost = values['cost'];
    return result;
  }

  @override
  Map<String, dynamic> toMap(Reward value) {
    return {
      'id': value.id,
      'name': value.name,
      'cost': value.cost,
    };
  }
}