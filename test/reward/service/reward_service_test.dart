import 'package:challengeapp/credit/service/credit_service.dart';
import 'package:challengeapp/reward/dao/bought_reward_dao.dart';
import 'package:challengeapp/reward/dao/reward_dao.dart';
import 'package:challengeapp/reward/model/bought_reward_model.dart';
import 'package:challengeapp/reward/model/reward_model.dart';
import 'package:challengeapp/reward/service/reward_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class BoughtRewardDaoMock extends Mock implements BoughtRewardDao {
  @override
  Future<BoughtReward> save(BoughtReward? value) =>
      super.noSuchMethod(
            Invocation.method(#save, [value]),
            returnValue: Future<BoughtReward>.value(value ?? BoughtReward()),
          )
          as Future<BoughtReward>;

  @override
  Future<BoughtReward?> getMostRecentByRewardId(int? rewardId) =>
      super.noSuchMethod(
            Invocation.method(#getMostRecentByRewardId, [rewardId]),
            returnValue: Future<BoughtReward?>.value(),
          )
          as Future<BoughtReward?>;
}

class CreditServiceMock extends Mock implements CreditService {
  @override
  Future<int> spendCredits(int? cost) => super.noSuchMethod(
    Invocation.method(#spendCredits, [cost]),
    returnValue: Future<int>.value(0),
  ) as Future<int>;
}

class RewardDaoMock extends Mock implements RewardDao {}

void main() {
  late BoughtReward bReward;
  late BoughtRewardDaoMock daoMock;
  late CreditServiceMock creditServiceMock;

  late RewardService subject;
  setUp(() {
    bReward = BoughtReward()
      ..id = 99
      ..rewardId = 1;
    daoMock = BoughtRewardDaoMock();
    creditServiceMock = CreditServiceMock();

    when(daoMock.getMostRecentByRewardId(1))
        .thenAnswer((_) => Future.value(bReward));
    when(
      daoMock.save(any),
    ).thenAnswer((v) => Future.value(v.positionalArguments[0] as BoughtReward));
    when(creditServiceMock.spendCredits(any)).thenAnswer((_) => Future.value(0));

    subject = RewardService(RewardDaoMock(), daoMock, creditServiceMock);
  });

  test('Test cache buyReward', () async {
    final boughtReward = await subject.buyReward(
      Reward()
        ..id = 1
        ..cost = 5,
    );
    expect(boughtReward, isNotNull);
    expect(boughtReward!.rewardId, 1);

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
