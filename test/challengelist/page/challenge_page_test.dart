import 'package:challengeapp/challengelist/i18n/challengelist_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/challengelist/service/challenge_service.dart';
import 'package:challengeapp/i18n/challenge_localization_delegate.dart';
import 'package:challengeapp/main.dart';
import 'package:mockito/mockito.dart';

import '../../home/page/challenge_home_page_model.dart';
import '../../mock_appcontext.dart';
import 'challenge_page_model.dart';

void main() {
  AppContextMock appContextMock;
  final commonI18n = ChallengeLocalizations(const Locale('en'));
  final challengeI18n = ChallengeListLocalizations(const Locale('en'));

  setUp(() async {
    appContextMock = AppContextMock();
  });

  testWidgets('Create challenge test', (WidgetTester tester) async {
    final homeModel = ChallengeHomePageModel(tester);
    final challengePageModel = ChallengePageModel(tester);

    final challengeService = appContextMock.appContext.get<ChallengeService>();
    final DateTime now = DateTime.now();

    final startChallenge = DateTime(now.year, now.month, 10);
    final dateDue = DateTime(now.year, now.month, 11);
    final dateLatest = DateTime(now.year, now.month, 15);

    final myApp = MyApp(container: appContextMock.appContext);
    await tester.pumpWidget(myApp);
    await tester.pumpAndSettle(); // yeah we have now to wait for flutter to load i18n resources, this is of course not documented

    // the day should be shown
    await homeModel.selectDay(10);
    await homeModel.goNewChallenge();

    expect(find.text(commonI18n.formatDate(startChallenge)), findsOneWidget);

    await challengePageModel.enterName('Test Challenge');

    // select a due at date
    await challengePageModel.enterDueAtDay(dateDue.day);
    expect(find.text(commonI18n.formatDate(dateDue)), findsOneWidget);
    expect(find.text(commonI18n.formatDate(startChallenge)), findsNothing);

    // select latest date
    await challengePageModel.enterLatestAtDay(dateLatest.day);
    expect(find.text(commonI18n.formatDate(dateLatest)), findsOneWidget);

    // enter reward
    await challengePageModel.enterReward(6);

    final c = verify(challengeService.save(captureAny)).captured.single as Challenge;
    expect(c.name, 'Test Challenge');
    expect(c.reward, 6);
    expect(c.createdAt, isNotNull);
    expect(c.createdAt.day, DateTime.now().day);
    expect(c.dueAt, dateDue);
    expect(c.latestAt, dateLatest);
  });

  testWidgets('Shows info if only today left to finish challenge', (WidgetTester tester) async {
    final now = DateTime.now();
    appContextMock.challenges.add(Challenge.of('First')
        ..dueAt = now
        ..latestAt = now
    );
    appContextMock.challenges.add(Challenge.of('Second')
      ..dueAt = now.add(const Duration(days: -1))
      ..latestAt = now
    );


    final myApp = MyApp(container: appContextMock.appContext);
    await tester.pumpWidget(myApp);
    await tester.pumpAndSettle();

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);

    expect(find.text(challengeI18n.challengeWillFail(const Duration())), findsNWidgets(2));

  });

}