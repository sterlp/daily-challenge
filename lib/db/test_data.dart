import 'package:challengeapp/challengelist/dao/challenge_dao.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/challengelist/service/challenge_service.dart';
import 'package:challengeapp/container/app_context.dart';
import 'package:challengeapp/credit/service/credit_service.dart';
import 'package:challengeapp/reward/dao/bought_reward_dao.dart';
import 'package:challengeapp/reward/dao/reward_dao.dart';
import 'package:challengeapp/reward/model/reward_model.dart';
import 'package:challengeapp/reward/service/reward_service.dart';
import 'package:challengeapp/util/random_util.dart';

class TestData {
  final ChallengeService _challengeService;
  final CreditService _creditService;
  final RewardService _rewardService;
  final ChallengeDao _challengeDao;
  final RewardDao _rewardDao;
  final BoughtRewardDao _boughtRewardDao;

  TestData.withContext(AppContext context) :
    _challengeService = context.get<ChallengeService>(),
    _creditService = context.get<CreditService>(),
    _rewardService = context.get<RewardService>(),
    _challengeDao = context.get<ChallengeDao>(),
    _rewardDao = context.get<RewardDao>(),
    _boughtRewardDao = context.get<BoughtRewardDao>();

  Future<void> deleteAll() async {
    return Future.wait([
      _challengeDao.deleteAll(),
      _rewardDao.deleteAll(),
      _boughtRewardDao.deleteAll()
    ]);
  }

  Future<void> generatePresentationData() async {
    var now = DateTime.now();
    await this._challengeService.save(Challenge.full('Rasen mähen', now.add(Duration(days: -1)), ChallengeStatus.open, 10));

    await this._challengeService.save(Challenge.full('Staubsaugen', DateTime.now(), ChallengeStatus.done, 5, now));

    await this._challengeService.save(Challenge.full('Staubsaugen', DateTime.now(), ChallengeStatus.done, 5, now.add(Duration(days: -5))));

    await this._challengeService.save(Challenge.full('Katzenklo machen', DateTime.now(), ChallengeStatus.done, 3, now));

    // should auto fail on first load
    await this._challengeService.save(Challenge.full('Müll raustragen', now.add(Duration(days: -8)), ChallengeStatus.open, 1));

    await this._challengeService.save(Challenge.full('10km laufen', now, ChallengeStatus.open, 3)
      ..latestAt = now);

    var schoki = await this._rewardDao.save(Reward()
      ..name = 'Ein Schokoriegel'
      ..cost = 3);

    await this._rewardDao.save(Reward()
      ..name = 'Ein Bier'
      ..cost = 5);

    await this._rewardDao.save(Reward()
      ..name = 'Neues Notebook'
      ..cost = 1500);

    _rewardService.buyReward(schoki);

    await _creditService.calcTotal();
  }

  Future<void> generateRandomChallengeData(int count, {int daysPast = 0, int daysFuture = 0}) async {
    var now = DateTime.now();
    await _newChallenges(count, now);
    
    if (daysPast > 0) {
      for(int i = daysPast; i > 0; --i) {
        await _newChallenges(count, now.add(Duration(days: -i)));
      }
    }
    if (daysFuture > 0) {
      for(int i = daysFuture; i > 0; --i) {
        await _newChallenges(count, now.add(Duration(days: i)));
      }
    }
  }

  Future<void> _newChallenges(int count, DateTime day) async {
    var toSave = List<Challenge>();
    for(int i = 0; i < count; ++i) {
      toSave.add(Challenge.full(
          RandomUtil.randomString(7) + ' ${i + 1}',
          day,
          i % 2 == 0 ? ChallengeStatus.open : ChallengeStatus.done, RandomUtil.randomInt(50))
      );
    }
    await this._challengeService.saveAll(toSave);
  }
}