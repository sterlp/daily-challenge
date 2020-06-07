import 'package:flutterapp/challengelist/models/challengeModel.dart';
import 'package:flutterapp/challengelist/services/challengeService.dart';

class TestData {
  final ChallengeService _challengeService;

  TestData(this._challengeService);

  Future<void> generateTestData() async {
    var now = DateTime.now();
    await this._challengeService.save(Challenge.withNameDateAndStatus('Rasen mähen', now.add(Duration(days: -1)), ChallengeStatus.open)
      ..reward = 10);
    await this._challengeService.save(Challenge.withNameDateAndStatus('Staubsaugen', DateTime.now(), ChallengeStatus.done)
      ..doneAt = now
      ..reward = 5);
    await this._challengeService.save(Challenge.withNameDateAndStatus('Müll raustragen', now.add(Duration(days: -8)), ChallengeStatus.open)
      ..reward = 1);

  }
}