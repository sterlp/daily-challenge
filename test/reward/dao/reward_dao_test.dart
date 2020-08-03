import 'package:flutter_test/flutter_test.dart';
import 'package:challengeapp/container/app_context.dart';
import 'package:challengeapp/db/db_provider.dart';
import 'package:challengeapp/reward/dao/reward_dao.dart';
import 'package:challengeapp/reward/model/reward_model.dart';

import '../../test_helper.dart';

void main() {
  AppContext context;
  RewardDao subject;

  setUp(() async {
    context = testContainer();
    await context.get<DbProvider>().db;
    subject = context.get<RewardDao>();
  });
  tearDown(() async {
    await subject.deleteAll();
    context.close();
  });

  test('Test save and load', () async {
    for (int i = 0; i < 10; ++i) {
      await subject.save(Reward()
        ..name = 'Foo $i'
        ..cost = i);
    }
    expect(await subject.countAll(), 10);

    var rewards = await subject.list(5, 0);
    expect(rewards.length, 5);

    expect(rewards[0].cost, 0);
    expect(rewards[4].cost, 4);

    rewards = await subject.list(5, 5);
    expect(rewards[0].cost, 5);
    expect(rewards[4].cost, 9);
  });
}