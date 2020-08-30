import 'package:challengeapp/util/date.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:challengeapp/challengelist/dao/challenge_dao.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/challengelist/service/challenge_service.dart';
import 'package:challengeapp/container/app_context.dart';
import 'package:challengeapp/db/test_data.dart';

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
    expect(8, (await challengeService.loadAll()).length);
  });

  test("Test complete", () async {

    var c = await challengeService.save(Challenge.of("Test 1")
      ..reward = 20);

    var result = await challengeService.complete([c]);
    expect(result, 20);

    expect( (await challengeDao.getById(c.id)).status, ChallengeStatus.done);
  });

  test("Test fail calculation of points", () async {
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

  test("Test fail date", () async {
    var c = await challengeService.save(Challenge.of("Test 1")
      ..latestAt = DateTime.now().add(Duration(days: -2))
      ..reward = 15);

    await challengeService.failOverDue([c]);
    expect( DateTimeUtil.midnight(c.latestAt), (await challengeService.getById(c.id)).doneAt);
  });

  test("Do not fail challenge same day today", () async {
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
    expect((await challengeService.loadAll()).length, 1);

    result = await challengeService.incomplete([c]);
    expect(result, 0);

    expect((await challengeService.loadAll()).length, 1);
  });

  test("Test count complete", () async {

    await challengeService.save(Challenge.of("Foo"));
    await challengeService.save(Challenge.of("Bar"));

    var c = await challengeService.save(Challenge.of("Test 1"));
    await challengeService.complete([c]);
    expect( (await challengeDao.countFinished()), 1);

    c = await challengeService.save(Challenge.of("Test 2"));
    await challengeService.complete([c]);
    expect( (await challengeDao.countFinished()), 2);
  });
}
