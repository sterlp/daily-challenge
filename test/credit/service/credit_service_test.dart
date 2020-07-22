import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/challengelist/dao/challenge_dao.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/container/app_context.dart';
import 'package:flutterapp/credit/service/credit_service.dart';
import 'package:flutterapp/db/db_provider.dart';
import 'package:flutterapp/reward/dao/bought_reward_dao.dart';
import 'package:flutterapp/reward/model/bought_reward_model.dart';

import '../../test_helper.dart';

void main() {
  AppContext appContext;
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

    await challengeDao.save(Challenge.withName("Test 1")
      ..reward = 99);
    result = await creditService.calcTotal();
    expect(result, 0);

    await challengeDao.save(Challenge.withName("Test 2")
      ..status = ChallengeStatus.done
      ..reward = 10);
    result = await creditService.calcTotal();
    expect(result, 10);

    await challengeDao.save(Challenge.withName("Test 3")
      ..status = ChallengeStatus.failed
      ..reward = 5);

    result = await creditService.calcTotal();
    expect(result, 5);
  });

  test("Test calcTotal with done challenge", () async {
    await challengeDao.save(Challenge.withName("Test 1")
      ..status = ChallengeStatus.done
      ..reward = 10);
    await challengeDao.save(Challenge.withName("Test 1")
      ..latestAt = DateTime.now().add(Duration(days: 2))
      ..reward = 20);

    var result = await creditService.calcTotal();
    expect(result, 10);
  });

  test("Test calcTotal with spend credits", () async {
    await challengeDao.save(Challenge.withName("Steuer")
      ..status = ChallengeStatus.done
      ..reward = 20);

    await boughtRewardDao.save(BoughtReward()
      ..cost = 1
      ..name = 'Schoki'
      ..rewardId = 1);
    await boughtRewardDao.save(BoughtReward()
      ..cost = 3
      ..name = 'Bier'
      ..rewardId = 2);

    await challengeDao.save(Challenge.withName("Saugen")
      ..status = ChallengeStatus.failed
      ..reward = 5);

    var result = await creditService.calcTotal();
    expect(result, 11);
  });
}