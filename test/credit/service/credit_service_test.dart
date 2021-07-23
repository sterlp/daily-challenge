import 'package:dependency_container/dependency_container.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:challengeapp/challengelist/dao/challenge_dao.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/credit/service/credit_service.dart';
import 'package:challengeapp/db/db_provider.dart';
import 'package:challengeapp/reward/dao/bought_reward_dao.dart';
import 'package:challengeapp/reward/model/bought_reward_model.dart';

import '../../test_helper.dart';

void main() {
  AppContainer appContext;
  ChallengeDao challengeDao;
  BoughtRewardDao boughtRewardDao;
  CreditService creditService;

  setUp(() async {
    appContext = testContainer();
    await appContext.get<DbProvider>().db;
    challengeDao = appContext.get<ChallengeDao>();
    boughtRewardDao = appContext.get<BoughtRewardDao>();
    creditService = appContext.get<CreditService>();

    await challengeDao.deleteAll();
    await boughtRewardDao.deleteAll();
  });

  tearDown(() async {
    appContext.close();
    appContext = null;
  });

  test("Test calcTotal with failed challenge", () async {

    int result = await creditService.calcTotal();
    expect(result, 0);

    await challengeDao.save(Challenge.of("Test 1", null, 99));
    result = await creditService.calcTotal();
    expect(result, 0);

    await challengeDao.save(Challenge.full("Test 2", null, ChallengeStatus.done, 10));
    result = await creditService.calcTotal();
    expect(result, 10);

    await challengeDao.save(Challenge.full("Test 3", null, ChallengeStatus.failed, 5));

    result = await creditService.calcTotal();
    expect(result, 5);
  });

  test("Test calcTotal with done challenge", () async {
    await challengeDao.save(Challenge.full("Test 1", null, ChallengeStatus.done, 10));
    await challengeDao.save(Challenge.full("Test 2", null, ChallengeStatus.open, 20));

    var result = await creditService.calcTotal();
    expect(result, 10);
  });

  test("Test calcTotal with spend credits", () async {
    await challengeDao.save(Challenge.full("Steuer", null, ChallengeStatus.done, 20));

    await boughtRewardDao.save(BoughtReward()
      ..cost = 1
      ..name = 'Schoki'
      ..rewardId = 1);
    await boughtRewardDao.save(BoughtReward()
      ..cost = 3
      ..name = 'Bier'
      ..rewardId = 2);

    await challengeDao.save(Challenge.full("Saugen", null, ChallengeStatus.failed, 5));

    var result = await creditService.calcTotal();
    expect(result, 11);
  });
}