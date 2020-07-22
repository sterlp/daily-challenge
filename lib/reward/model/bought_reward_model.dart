import 'package:flutterapp/reward/model/reward_model.dart';

class BoughtReward extends Reward {
  BoughtReward();
  BoughtReward.fromReward(Reward r) {
    name = r.name;
    rewardId = r.id;
    cost = r.cost;
  }

  DateTime boughtAt = DateTime.now();
  int rewardId;

  @override
  String toString() {
    return 'BoughtReward[id=$id, name=$name, cost=$cost, boughtAt=$boughtAt, rewardId=$rewardId]';
  }
}