import 'package:flutter_test/flutter_test.dart';
import 'package:challengeapp/container/app_context.dart';
import 'package:challengeapp/reward/dao/bought_reward_dao.dart';
import 'package:challengeapp/reward/model/bought_reward_model.dart';

import '../../test_helper.dart';

void main() {
  AppContext context;
  BoughtRewardDao subject;

  setUp(() {
    context = testContainer();
    subject = context.get<BoughtRewardDao>();
  });
  tearDown(() async {
    await subject.deleteAll();
    context.close();
  });

  test('Test save and load', () async {
    for (int i = 0; i < 10; ++i) {
      await subject.save(BoughtReward()
        ..name = 'Foo $i'
        ..cost = i
        ..rewardId = 1
        ..boughtAt = DateTime.now().add(Duration(days: i)));
    }
    expect(await subject.countAll(), 10);

    var rewards = await subject.list(5, 0);
    expect(rewards.length, 5);
    // we expect here a reverse order as we changed the date, otherwise it would be the same test as for the reward
    // this would be quite boring
    expect(rewards[0].cost, 9);
    expect(rewards[4].cost, 5);

    rewards = await subject.list(5, 5);
    expect(rewards[0].cost, 4);
    expect(rewards[4].cost, 0);
  });

  test('Test getMostRecentByRewardId', () async {
      await subject.save(BoughtReward()
        ..name = 'Old Foo'
        ..rewardId = 1
        ..boughtAt = DateTime.now().add(Duration(days: -1)));
      await subject.save(BoughtReward()
        ..name = 'New Foo'
        ..rewardId = 1
        ..boughtAt = DateTime.now());

      var reward = await subject.getMostRecentByRewardId(1);
      expect(reward.name, 'New Foo');

      reward = await subject.getMostRecentByRewardId(2);
      expect(reward, isNull);
  });
}