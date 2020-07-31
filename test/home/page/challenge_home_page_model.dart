import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../page_model/page_model.dart';

class ChallengeHomePageModel extends PageModel {

  ChallengeHomePageModel(WidgetTester tester) : super(tester);

  Future<void> goChallengeTab() async {
    await tester.tap(find.text(i18n.challengeTab));
    await tester.pumpAndSettle();
  }
  Future<void> goRewardTab() async {
    await tester.tap(find.text(i18n.rewardTab));
    await tester.pumpAndSettle();
  }
  Future<void> goNewChallenge() async {
    await tester.tap(find.text(challengeI18n.newChallengeButton));
    await tester.pumpAndSettle();

    // we should see the new header ...
    expect(find.text(challengeI18n.createChallengeHeader), findsOneWidget);
  }

  Future<void> selectDay(int day) async {
    await tester.tap(find.byKey(ValueKey('home_day_select')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(day.toString()));
    await tester.pumpAndSettle();
    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();
  }
}