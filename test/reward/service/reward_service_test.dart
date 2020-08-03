import 'package:flutter_test/flutter_test.dart';
import 'package:challengeapp/credit/service/credit_service.dart';
import 'package:challengeapp/reward/dao/bought_reward_dao.dart';
import 'package:challengeapp/reward/model/bought_reward_model.dart';
import 'package:challengeapp/reward/model/reward_model.dart';
import 'package:challengeapp/reward/service/reward_service.dart';
import 'package:mockito/mockito.dart';

class BoughtRewardDaoMock extends Mock implements BoughtRewardDao {}
class CreditServiceMock extends Mock implements CreditService {}

main() {
  BoughtReward bReward;
  BoughtRewardDaoMock daoMock;
  CreditServiceMock creditServiceMock;

  RewardService subject;
  setUp(() {
    bReward = BoughtReward()
      ..id = 99
      ..rewardId = 1;
    daoMock = BoughtRewardDaoMock();
    creditServiceMock = CreditServiceMock();

    when(daoMock.getMostRecentByRewardId(1)).thenAnswer((_) => Future.value(bReward));
    when(daoMock.save(any)).thenAnswer((v) => Future.value(v.positionalArguments[0]));

    subject = RewardService(null, daoMock, creditServiceMock);
  });

  test('Test cache buyReward', () async {
    var boughtReward = await subject.buyReward(Reward()
      ..id = 1
      ..cost=5);
    expect(boughtReward, isNotNull);
    expect(boughtReward.rewardId, 1);

    verify(daoMock.save(boughtReward)).called(1);
    verify(creditServiceMock.spendCredits(5)).called(1);

    // cache should be update using buyReward
    expect(await subject.getLastBoughtRewardByRewardId(1), boughtReward);
    verifyNever(daoMock.getMostRecentByRewardId(1));
  });

  test('Test cache getMostRecentByRewardId', () async {
    expect(await subject.getLastBoughtRewardByRewardId(1), bReward);
    expect(await subject.getLastBoughtRewardByRewardId(1), bReward);
    expect(await subject.getLastBoughtRewardByRewardId(1), bReward);

    verify(daoMock.getMostRecentByRewardId(1)).called(1);
  });
}