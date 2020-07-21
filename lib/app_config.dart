import 'package:flutterapp/challengelist/dao/challenge_dao.dart';
import 'package:flutterapp/challengelist/service/challenge_service.dart';
import 'package:flutterapp/container/app_context.dart';
import 'package:flutterapp/db/db_provider.dart';
import 'package:flutterapp/db/test_data.dart';
import 'package:flutterapp/reward/dao/bought_reward_dao.dart';
import 'package:flutterapp/reward/dao/reward_dao.dart';
import 'package:flutterapp/reward/service/reward_service.dart';
import 'package:sqflite/sqflite.dart';

AppContext buildContext([Future<Database> database]) {
  return new AppContext()
    // lazy init of the beans to give Flutter the time to start before we init the DB, otherwise we face:
    // Unhandled Exception: ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized.
    ..addFactory((_) => database == null ? DbProvider() : DbProvider.withDb(database))
    ..addFactory((rattlinger) => ChallengeDao(rattlinger.get<DbProvider>().db))
    ..addFactory((rattlinger) => ChallengeService(rattlinger.get<ChallengeDao>()))
    ..addFactory((rattlinger) => RewardDao(rattlinger.get<DbProvider>().db))
    ..addFactory((rattlinger) => BoughtRewardDao(rattlinger.get<DbProvider>().db))
    ..addFactory((rattlinger) => RewardService(rattlinger.get<RewardDao>(), rattlinger.get<BoughtRewardDao>()))
    ..addFactory((rattlinger) => TestData(rattlinger.get<ChallengeService>()));
}
