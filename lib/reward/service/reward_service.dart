
import 'package:flutterapp/reward/dao/bought_reward_dao.dart';
import 'package:flutterapp/reward/dao/reward_dao.dart';
import 'package:flutterapp/reward/model/bought_reward_model.dart';
import 'package:flutterapp/reward/model/reward_model.dart';

class RewardService {
  final RewardDao _rewardDao;
  final BoughtRewardDao _boughtRewardDao;

  RewardService(this._rewardDao, this._boughtRewardDao);

  Future<Reward> save(Reward reward) {
    return _rewardDao.save(reward);
  }

  Future<List<Reward>> listRewards(int limit, int offset) {
    return _rewardDao.list(limit, offset);
  }
}