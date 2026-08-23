import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Challenge withName', () {
    final Challenge subject = Challenge.of('test');

    // Verify that our counter starts at 0.
    expect(subject.name, 'test');
    expect(subject.status, ChallengeStatus.open);
    expect(
      subject.createdAt.millisecondsSinceEpoch <=
          DateTime.now().millisecondsSinceEpoch,
      true,
    );
  });

  test('Challenge latestAt div', () {
    final subject = Challenge.of('test')..latestAt = DateTime.now();

    expect(subject.latestDiff(DateTime.now()).inDays, 0);

    subject.latestAt = subject.latestAt!.add(const Duration(days: 1));
    expect(subject.latestDiff(DateTime.now()).inDays, 1);

    subject.latestAt = subject.latestAt!.add(const Duration(days: 1));
    expect(subject.latestDiff(DateTime.now()).inDays, 2);
  });
}
