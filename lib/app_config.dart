import 'package:challengeapp/challengelist/dao/challenge_dao.dart';
import 'package:challengeapp/challengelist/service/challenge_service.dart';
import 'package:challengeapp/config/service/config_service.dart';
import 'package:challengeapp/container/app_context.dart';
import 'package:challengeapp/credit/service/credit_service.dart';
import 'package:challengeapp/db/db_provider.dart';
import 'package:challengeapp/db/test_data.dart';
import 'package:challengeapp/history/service/history_service.dart';
import 'package:challengeapp/reward/dao/bought_reward_dao.dart';
import 'package:challengeapp/reward/dao/reward_dao.dart';
import 'package:challengeapp/reward/service/reward_service.dart';
import 'package:sqflite/sqflite.dart';

AppContext buildContext([Future<Database> database]) {
  return new AppContext()
    // lazy init of the beans to give Flutter the time to start before we init the DB, otherwise we face:
    // Unhandled Exception: ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized.
    ..addFactory((_) => database == null ? DbProvider() : DbProvider.withDb(database))

    ..addFactory((rattlinger) => ConfigService())
    ..addFactory<Future<Database>>((rattlinger) => rattlinger.get<DbProvider>().db)

    ..addFactory((rattlinger) => CreditService(rattlinger.get<ChallengeDao>(), rattlinger.get<BoughtRewardDao>()))

    ..addFactory((rattlinger) => ChallengeDao(rattlinger.get<Future<Database>>()))
    ..addFactory((rattlinger) => ChallengeService(rattlinger.get<ChallengeDao>(), rattlinger.get<CreditService>()))

    ..addFactory((rattlinger) => RewardDao(rattlinger.get<Future<Database>>()))
    ..addFactory((rattlinger) => BoughtRewardDao(rattlinger.get<Future<Database>>()))
    ..addFactory((rattlinger) => RewardService(rattlinger.get<RewardDao>(), rattlinger.get<BoughtRewardDao>(), rattlinger.get<CreditService>()))

    ..addFactory((rattlinger) => HistoryService(rattlinger.get<RewardService>(), rattlinger.get<ChallengeService>()))

    ..addFactory((rattlinger) => TestData.withContext(rattlinger));

}
