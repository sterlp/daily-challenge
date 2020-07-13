import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/challengelist/dao/challenge_dao.dart';
import 'package:flutterapp/challengelist/models/challenge_model.dart';
import 'package:flutterapp/challengelist/services/challenge_service.dart';
import 'package:flutterapp/db/db_provider.dart';
import 'package:flutterapp/db/test_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  Future<Database> db;
  ChallengeDao challengeDao;
  ChallengeService challengeService;

  setUp(() async {
    sqfliteFfiInit();
    db = databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    challengeDao = ChallengeDao(DbProvider.withDb(db).db);
    challengeService = ChallengeService(challengeDao);
  });

  tearDown(() async {
    (await db).close();
    db = null;
  });

  test("Test generateTestData", () async {
    await TestData(challengeService).generatePresentationData();
    expect(3, (await challengeService.load()).length);
  });

  test("Test count open", () async {

    int result = await challengeService.calcTotal();
    expect(result, 0);

    await challengeService.save(Challenge.withName("Test 1")
      ..reward = 20);
    await challengeService.save(Challenge.withName("Test 2")
      ..status = ChallengeStatus.done
      ..reward = 10);
    await challengeService.save(Challenge.withName("Test 2")
      ..status = ChallengeStatus.done
      ..reward = 5);

    result = await challengeService.calcTotal();
    expect(result, 15);
  });

  test("Test complete", () async {

    var c = await challengeService.save(Challenge.withName("Test 1")
      ..reward = 20);

    var result = await challengeService.complete([c]);
    expect(result, 20);
  });

  test("Test getTotal", () async {
    await challengeService.save(Challenge.withName("Test 1")
      ..status = ChallengeStatus.done
      ..reward = 10);
    await challengeService.save(Challenge.withName("Test 1")
      ..latestAt = DateTime.now().add(Duration(days: 2))
      ..reward = 20);

    var result = await challengeService.getTotal();
    expect(result, 10);
  });

  test("Test fail", () async {
    await challengeService.save(Challenge.withName("Test 1")
      ..status = ChallengeStatus.done
      ..reward = 9);
    var c = await challengeService.save(Challenge.withName("Test 1")
      ..latestAt = DateTime.now().add(Duration(days: -1))
      ..reward = 15);

    var result = await challengeService.failOverDue([c]);
    expect(result, -6);
    expect(ChallengeStatus.failed, (await challengeService.getById(c.id)).status);
  });

  test("Test not fail challenge same day today", () async {
    var c = await challengeService.save(Challenge.withName("Test 1")
      ..latestAt = DateTime.now().add(Duration(minutes: -1))
      ..reward = 15);

    var result = await challengeService.failOverDue([c]);
    expect(result, 0);

    c.latestAt = c.latestAt.add(Duration(days: -1));
    result = await challengeService.failOverDue([c]);
    expect(result, -15);
  });

  test("Test incomplete", () async {

    var c = await challengeService.save(Challenge.withName("Test 1")
      ..reward = 20);

    var result = await challengeService.complete([c]);
    expect(result, 20);
    expect((await challengeService.load()).length, 1);

    result = await challengeService.incomplete([c]);
    expect(result, 0);

    expect((await challengeService.load()).length, 1);
  });
}
