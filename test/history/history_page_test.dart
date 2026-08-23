import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/i18n/challenge_localization_delegate.dart';
import 'package:challengeapp/main.dart';
import 'package:challengeapp/reward/model/bought_reward_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_context.dart';

void main() {
  late AppContextMock appContextMock;
  final i18n = ChallengeLocalizations(const Locale('en'));

  setUp(() {
    appContextMock = AppContextMock();
    when(appContextMock.challengeServiceMock.listCompleted())
        .thenAnswer((_) => Future.value(<Challenge>[]));
    when(appContextMock.rewardServiceMock.listBoughtRewards())
        .thenAnswer((_) => Future.value(<BoughtReward>[]));
  });

  testWidgets('History shows completed challenge on tab activation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(container: appContextMock.appContext));
    await tester.pumpAndSettle();

    // visit history once -> empty
    await tester.tap(find.text(i18n.historyTab));
    await tester.pumpAndSettle();
    expect(find.text('Done Challenge'), findsNothing);

    // complete a challenge while another tab is active
    final done = Challenge.full('Done Challenge', null, ChallengeStatus.done)
      ..id = 1;
    when(appContextMock.challengeServiceMock.listCompleted())
        .thenAnswer((_) => Future.value(<Challenge>[done]));

    // leave history
    await tester.tap(find.text(i18n.challengeTab));
    await tester.pumpAndSettle();

    // return to history -> the completed challenge must be visible
    await tester.tap(find.text(i18n.historyTab));
    await tester.pumpAndSettle();

    expect(find.text('Done Challenge'), findsOneWidget);
  });

  testWidgets('History stays up to date after buying a reward', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(container: appContextMock.appContext));
    await tester.pumpAndSettle();

    // visit history once -> empty
    await tester.tap(find.text(i18n.historyTab));
    await tester.pumpAndSettle();
    expect(find.text('Bought Reward'), findsNothing);

    // buy a reward while another tab is active
    final bought = BoughtReward()
      ..id = 2
      ..name = 'Bought Reward'
      ..cost = 5
      ..boughtAt = DateTime.now();
    when(appContextMock.rewardServiceMock.listBoughtRewards())
        .thenAnswer((_) => Future.value(<BoughtReward>[bought]));

    // leave and return to history
    await tester.tap(find.text(i18n.challengeTab));
    await tester.pumpAndSettle();
    await tester.tap(find.text(i18n.historyTab));
    await tester.pumpAndSettle();

    expect(find.text('Bought Reward'), findsOneWidget);
  });
}
