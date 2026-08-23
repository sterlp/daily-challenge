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
    final bought = await _rewardService.countBoughtRewards();
    final doneChallenges = await _challengeService.countFinished();
    return bought + doneChallenges;
  }

  Future<List<HistoryChallengeOrBoughtReward>> loadHistory() {
    final resultCompleter = Completer<List<HistoryChallengeOrBoughtReward>>();

    Future.wait([
      _rewardService.listBoughtRewards(),
      _challengeService.listCompleted(),
    ]).then(
      (values) {
        // both lists are sorted newest first
        final List<BoughtReward> rewards =
            values[0].toList() as List<BoughtReward>;
        final List<Challenge> challenges =
            values[1].toList() as List<Challenge>;

        final result = <HistoryChallengeOrBoughtReward>[];
        var ri = 0;
        var ci = 0;

        while (ri < rewards.length || ci < challenges.length) {
          final BoughtReward? r = ri < rewards.length ? rewards[ri] : null;
          final Challenge? c = ci < challenges.length ? challenges[ci] : null;

          if (c == null || (r != null && !r.boughtAt.isBefore(c.doneAt!))) {
            result.add(HistoryChallengeOrBoughtReward(r, null));
            ri++;
          } else {
            result.add(HistoryChallengeOrBoughtReward(null, c));
            ci++;
          }
        }
        resultCompleter.complete(result);
      },
      onError: (Object e) {
        resultCompleter.completeError(e);
      },
    );

    return resultCompleter.future;
  }
}
