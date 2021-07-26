import 'package:challengeapp/util/date.dart';
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:challengeapp/challengelist/dao/challenge_dao.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/challengelist/service/challenge_service.dart';
import 'package:challengeapp/db/test_data.dart';

import '../../test_helper.dart';

void main() {
  AppContainer appContext;
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

    final c = await challengeService.save(Challenge.of("Test 1")
      ..reward = 20);

    final result = await challengeService.complete([c]);
    expect(result, 20);

    expect( (await challengeDao.getById(c.id)).status, ChallengeStatus.done);
  });

  test("Test fail calculation of points", () async {
    await challengeService.save(Challenge.of("Test 1")
      ..status = ChallengeStatus.done
      ..reward = 9);
    final c = await challengeService.save(Challenge.of("Test 1")
      ..latestAt = DateTime.now().add(const Duration(days: -1))
      ..reward = 15);

    final result = await challengeService.failOverDue([c]);
    expect(result, -6);
    expect(ChallengeStatus.failed, (await challengeService.getById(c.id)).status);
  });

  test("Test fail date", () async {
    final c = await challengeService.save(Challenge.of("Test 1")
      ..latestAt = DateTime.now().add(const Duration(days: -2))
      ..reward = 15);

    await challengeService.failOverDue([c]);
    expect( DateTimeUtil.midnight(c.latestAt), (await challengeService.getById(c.id)).doneAt);
  });

  test("Do not fail challenge same day today", () async {
    final c = await challengeService.save(Challenge.of("Test 1")
      ..latestAt = DateTime.now().add(const Duration(minutes: -1))
      ..reward = 15);

    var result = await challengeService.failOverDue([c]);
    expect(result, 0);

    c.latestAt = c.latestAt.add(const Duration(days: -1));
    result = await challengeService.failOverDue([c]);
    expect(result, -15);
  });

  test("Test incomplete", () async {

    final c = await challengeService.save(Challenge.of("Test 1")
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
    expect(await challengeDao.countFinished(), 1);

    c = await challengeService.save(Challenge.of("Test 2"));
    await challengeService.complete([c]);
    expect(await challengeDao.countFinished(), 2);
  });

  test("Will fail overdue challenges", () async {
    final now = DateTime.now();

    await challengeService.save(Challenge.of("Day before yesterday")
      ..dueAt = now.add(const Duration(days: -2))
      ..latestAt = now.add(const Duration(days: -1)));
    await challengeService.save(Challenge.of("Yesterday")
      ..dueAt = now.add(const Duration(days: -1))
      ..latestAt = now.add(const Duration(days: -1)));
    await challengeService.save(Challenge.of("Today")
      ..dueAt = now
      ..latestAt = now);

    // load only today
    var result = await challengeService.loadByDate(now, false);
    expect(result.length, 1);
    expect(result[0].name, 'Today');

    result = await challengeService.loadByDate(now, true);
    expect(result.length, 3);

    expect(result[0].name, 'Today');
    expect(result[1].name, 'Day before yesterday');
    expect(result[1].status, ChallengeStatus.failed);
    expect(result[2].name, 'Yesterday');
    expect(result[2].status, ChallengeStatus.failed);
  });

  test("Sort overdue and current by latestAt Date, failed in the ned", () async {
    final now = DateTime.now();

    await challengeService.save(Challenge.of("Failed")
      ..dueAt = now.add(const Duration(days: -2))
      ..latestAt = now.add(const Duration(days: -1)));

    await challengeService.save(Challenge.of("Overdue")
      ..dueAt = now.add(const Duration(days: -2))
      ..latestAt = now);

    await challengeService.save(Challenge.of("New")
      ..dueAt = now);

    await challengeService.save(Challenge.of("Tomorrow")
      ..dueAt = now.add(const Duration(days: 1)));

    final result = await challengeService.loadByDate(now, true);
    expect(result.length, 3);

    expect(result[0].name, 'New');
    expect(result[1].name, 'Overdue');
    expect(result[2].name, 'Failed');

  });
}
