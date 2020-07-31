import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../page_model/page_model.dart';

class ChallengePageModel extends AbstractPageModel  {
  ChallengePageModel(WidgetTester tester) : super(tester);

  Finder get nameInput => find.byKey(ValueKey('challenge_name'));

  Future<void> enterName(String value) async {
    await tester.enterText(nameInput, value);
    await tester.pumpAndSettle();
  }

  Future<void> enterDueAtDay(int day) async {
    await tester.tap(find.text(challengeI18n.challengeDueAt.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(day.toString()));
    await tester.pumpAndSettle();
    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();
  }

  Future<void> enterLatestAtDay(int day) async {
    await tester.tap(find.text(challengeI18n.challengeLatestAt.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(day.toString()));
    await tester.pumpAndSettle();
    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();
  }

  Future<void> enterReward(int reward) async {
    await tester.tap(find.text(challengeI18n.challengeReward.label));
    await tester.enterText(find.byType(TextFormField).at(2), reward.toString());
    await tester.tap(find.text(i18n.buttonCreate));
    await tester.pumpAndSettle();
  }
}