import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/reward/model/bought_reward_model.dart';

class HistoryChallengeOrBoughtReward {
  final BoughtReward? reward;
  final Challenge? challenge;

  bool get isReward => reward != null;
  bool get isChallenge => challenge != null;

  String get key =>
      isReward ? 'BoughtReward_${reward!.id}' : 'Challenge_${challenge!.id}';
  String get name => isReward ? reward!.name : challenge!.name;
  int get points => isReward
      ? -reward!.cost
      : challenge!.isFailed
      ? -challenge!.reward
      : challenge!.reward;
  DateTime? get at => isReward ? reward!.boughtAt : challenge!.doneAt;

  HistoryChallengeOrBoughtReward(this.reward, this.challenge)
    : assert(
        (reward == null) != (challenge == null),
        'Provide only one of both fields, this object should contain only one of both fields.',
      );
}
