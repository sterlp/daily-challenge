import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/challengelist/service/challenge_service.dart';
import 'package:flutterapp/util/random_util.dart';

class TestData {
  final ChallengeService _challengeService;

  TestData(this._challengeService);

  Future<void> generatePresentationData() async {
    var now = DateTime.now();
    await this._challengeService.save(Challenge.withNameDateAndStatus('Rasen mähen', now.add(Duration(days: -1)), ChallengeStatus.open)
      ..reward = 10);
    await this._challengeService.save(Challenge.withNameDateAndStatus('Staubsaugen', DateTime.now(), ChallengeStatus.done)
      ..doneAt = now
      ..reward = 5);
    await this._challengeService.save(Challenge.withNameDateAndStatus('Müll raustragen', now.add(Duration(days: -8)), ChallengeStatus.open)
      ..reward = 1);

  }

  Future<void> generateData(int count, {int daysPast = 0, int daysFuture = 0}) async {
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
      toSave.add(Challenge.withNameDateAndStatus(
          RandomUtil.randomString(7) + ' ${i + 1}',
          day,
          i % 2 == 0 ? ChallengeStatus.open : ChallengeStatus.done)
        ..reward = RandomUtil.randomInt(50)
      );
    }
    await this._challengeService.saveAll(toSave);
  }
}