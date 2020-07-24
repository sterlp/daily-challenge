import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/challengelist/dao/challenge_dao.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/challengelist/service/challenge_service.dart';
import 'package:flutterapp/container/app_context.dart';
import 'package:flutterapp/db/test_data.dart';

import '../../test_helper.dart';

void main() {
  AppContext appContext;
  ChallengeDao challengeDao;
  ChallengeService challengeService;

  setUp(() async {
    appContext = testContainer();
    challengeDao = appContext.get<ChallengeDao>();
    await appContext.get<TestData>().deleteAll();
    challengeService = appContext.get<ChallengeService>();
  });

  tearDown(() async {
    appContext.close();
    appContext = null;
  });

  test("Test generateTestData", () async {
    await appContext.get<TestData>().generatePresentationData();
    expect(6, (await challengeService.load()).length);
  });

  test("Test complete", () async {

    var c = await challengeService.save(Challenge.of("Test 1")
      ..reward = 20);

    var result = await challengeService.complete([c]);
    expect(result, 20);

    expect( (await challengeDao.getById(c.id)).status, ChallengeStatus.done);
  });

  test("Test fail", () async {
    await challengeService.save(Challenge.of("Test 1")
      ..status = ChallengeStatus.done
      ..reward = 9);
    var c = await challengeService.save(Challenge.of("Test 1")
      ..latestAt = DateTime.now().add(Duration(days: -1))
      ..reward = 15);

    var result = await challengeService.failOverDue([c]);
    expect(result, -6);
    expect(ChallengeStatus.failed, (await challengeService.getById(c.id)).status);
  });

  test("Test not fail challenge same day today", () async {
    var c = await challengeService.save(Challenge.of("Test 1")
      ..latestAt = DateTime.now().add(Duration(minutes: -1))
      ..reward = 15);

    var result = await challengeService.failOverDue([c]);
    expect(result, 0);

    c.latestAt = c.latestAt.add(Duration(days: -1));
    result = await challengeService.failOverDue([c]);
    expect(result, -15);
  });

  test("Test incomplete", () async {

    var c = await challengeService.save(Challenge.of("Test 1")
      ..reward = 20);

    var result = await challengeService.complete([c]);
    expect(result, 20);
    expect((await challengeService.load()).length, 1);

    result = await challengeService.incomplete([c]);
    expect(result, 0);

    expect((await challengeService.load()).length, 1);
  });
}
