import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/challengelist/service/challenge_service.dart';
import 'package:challengeapp/db/test_data.dart';
import 'package:challengeapp/history/service/history_service.dart';
import 'package:challengeapp/reward/model/reward_model.dart';
import 'package:challengeapp/reward/service/reward_service.dart';
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helper.dart';

void main() {
  late AppContainer appContext;
  late HistoryService historyService;

  setUp(() async {
    appContext = testContainer();
    await appContext.get<TestData>().deleteAll();
    historyService = appContext.get<HistoryService>();
  });

  tearDown(() {
    appContext.close();
  });

  test('loadHistory contains completed challenge', () async {
    final challengeService = appContext.get<ChallengeService>();
    final c = await challengeService.save(Challenge.of('Done Challenge'));
    await challengeService.complete([c]);

    // ignore: avoid_print
    for (final ch in await appContext.get<ChallengeService>().listCompleted()) {
      // ignore: avoid_print
      print('COMPLETED: ${ch.name} status=${ch.status}');
    }
    // ignore: avoid_print
    for (final b in await appContext.get<RewardService>().listBoughtRewards()) {
      // ignore: avoid_print
      print('BOUGHT: ${b.name}');
    }
    final history = await historyService.loadHistory();

    expect(
      history.where((e) => e.isChallenge && e.challenge!.isDone),
      isNotEmpty,
    );
  });

  test('loadHistory merges challenges and rewards chronologically', () async {
    final challengeService = appContext.get<ChallengeService>();
    final rewardService = appContext.get<RewardService>();

    final c = await challengeService.save(Challenge.of('Done Challenge'));
    await challengeService.complete([c]);
    final r = Reward()
      ..name = 'Test Reward'
      ..cost = 1;
    await rewardService.save(r);
    await rewardService.buyReward(r);

    final history = await historyService.loadHistory();
    expect(history.length, 2);
    expect(history.where((e) => e.isReward), hasLength(1));
    expect(
      history.where((e) => e.isChallenge && e.challenge!.isDone),
      hasLength(1),
    );
    // newest first
    expect(
      history.first.at!.isAfter(history.last.at!) ||
          history.first.at == history.last.at,
      isTrue,
    );
  });
}
