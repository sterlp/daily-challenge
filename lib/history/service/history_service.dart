import 'dart:async';

import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/challengelist/service/challenge_service.dart';
import 'package:challengeapp/history/model/history_model.dart';
import 'package:challengeapp/reward/model/bought_reward_model.dart';
import 'package:challengeapp/reward/service/reward_service.dart';

class HistoryService {
  final RewardService _rewardService;
  final ChallengeService _challengeService;

  HistoryService(this._rewardService, this._challengeService);

  Future<int> loadTotal() async {
    final _bought = await this._rewardService.countBoughtRewards();
    final _doneChallenges = await this._challengeService.countFinished();
    return _bought + _doneChallenges;
  }

  Future<List<HistoryChallengeOrBoughtReward>> loadHistory() {
    final resultCompleter = Completer<List<HistoryChallengeOrBoughtReward>>();

    Future.wait([
      _rewardService.listBoughtRewards(),
      _challengeService.listCompleted()])
        .then((values) {

          final List<BoughtReward> rewards = values[0].reversed.toList() as List<BoughtReward>;
          final List<Challenge> challenges = values[1].reversed.toList() as List<Challenge>;

          final result = <HistoryChallengeOrBoughtReward>[];
          BoughtReward r; Challenge c;

          while(rewards.isNotEmpty || challenges.isNotEmpty) {
            if (rewards.isNotEmpty && r == null) r = rewards.removeLast();
            if (challenges.isNotEmpty && c == null) c = challenges.removeLast();

            if (c != null && r != null) {
              if (r.boughtAt.isBefore(c.doneAt)) {
                result.add(HistoryChallengeOrBoughtReward(null, c));
                c = null;
              } else {
                result.add(HistoryChallengeOrBoughtReward(r, null));
                r = null;
              }
            } else if (c == null) {
              // end of challenges
              result.add(HistoryChallengeOrBoughtReward(r, null));
              r = null;
            } else /* if (r == null)*/ {
              // end of rewards
              result.add(HistoryChallengeOrBoughtReward(null, c));
              c = null;
            }
          }
          resultCompleter.complete(result);
        }
      ).catchError((e) => resultCompleter.completeError(e));

    return resultCompleter.future;
  }
}