import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:challengeapp/challengelist/dao/challenge_dao.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/log/logger.dart';
import 'package:challengeapp/reward/dao/bought_reward_dao.dart';

///
/// Responsible to manage the total credits and any calculation to it.
///
class CreditService {
  static final Logger _log = LoggerFactory.get<CreditService>();
  final ChallengeDao _challengeDao;
  final BoughtRewardDao _boughtRewardDao;
  final _credit = ValueNotifier<int>(null);

  CreditService(this._challengeDao, this._boughtRewardDao);

  ValueNotifier<int> get creditNotifier => _credit;

  Future<int> get credit {
    if (_credit.value == null) return calcTotal();
    else return Future.value(_credit.value);
  }

  Future<int> calcTotal() {
    _log.startSync('calcTotal');
    final completer = Completer<int>();
    final done = _challengeDao.sumByStatus(ChallengeStatus.done);
    final failed = _challengeDao.sumByStatus(ChallengeStatus.failed);
    final spend = _boughtRewardDao.sum();

    Future.wait([done, failed, spend]).then((values) {
      final int done = values[0];
      final int failed = values[1];
      final int spend = values[2];
      final int result = done - failed - spend;
      _log.finishSync('calcTotal -> done($done) - failed($failed) - spend($spend) = $result');

      if (_credit.value != result) _credit.value = result;
      completer.complete(result);
    }).catchError((e) => completer.completeError(e));
    return completer.future;
  }

  Future<int> spendCredits(int cost) {
    return credit.then((value) {
      final result = value - cost;
      _credit.value = result;
      return result;
    });
  }
}