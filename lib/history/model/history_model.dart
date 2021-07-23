import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/reward/model/bought_reward_model.dart';
import 'package:flutter/material.dart';

class HistoryChallengeOrBoughtReward {
  final BoughtReward reward;
  final Challenge challenge;

  bool get isReward => reward != null;
  bool get isChallenge => challenge != null;

  String get key => isReward ? 'BoughtReward_${reward.id}' : 'Challenge_${challenge.id}';
  String get name => isReward ? reward.name : challenge.name;
  int get points => isReward ? -reward.cost : challenge.isFailed ? -challenge.reward : challenge.reward;
  DateTime get at => isReward ? reward.boughtAt : challenge.doneAt;

  HistoryChallengeOrBoughtReward(this.reward, this.challenge) {
    assert(() {
      if (reward == null && challenge == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('HistoryChallengeOrBoughtReward only null values!'),
          ErrorDescription(
            'Neither BoughtReward nor Challenge was provided in the constructor of the HistoryChallengeOrBoughtReward.'
          ),
          ErrorHint(
              'Provide one of both fields, as it makes no sense to to have only null values.'
          ),
        ]);
      } else if (reward != null && challenge != null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('HistoryChallengeOrBoughtReward has BoughtReward and a Challenge!'),
          ErrorDescription(
              'Both BoughtReward and Challenge was provided in the constructor of the HistoryChallengeOrBoughtReward.'
          ),
          ErrorHint(
              'Provide only one of both fields, this object should contain only one of both fields.'
          ),
        ]);
      }
      return true;
    }());
  }
}