import 'package:flutterapp/reward/model/reward_model.dart';

class BoughtReward extends Reward {

  DateTime boughtAt;

  @override
  String toString() {
    return '$this[id=$id, name=$name, cost=$cost, boughtAt=$boughtAt]';
  }
}