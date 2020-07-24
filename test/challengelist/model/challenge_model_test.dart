import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';

void main() {
  test('Challenge withName', () {
    final Challenge subject = Challenge.of('test');

    // Verify that our counter starts at 0.
    expect(subject.name, 'test');
    expect(subject.status, ChallengeStatus.open);
    expect(subject.createdAt.millisecondsSinceEpoch <= DateTime.now().millisecondsSinceEpoch, true);
  });
}
