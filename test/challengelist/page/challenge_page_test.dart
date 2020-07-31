import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/challengelist/service/challenge_service.dart';
import 'package:flutterapp/i18n/challenge_localization_delegate.dart';
import 'package:flutterapp/main.dart';
import 'package:mockito/mockito.dart';

import '../../home/page/challenge_home_page_model.dart';
import '../../mock_appcontext.dart';
import 'challenge_page_model.dart';

void main() {
  AppContextMock appContextMock;
  final ChallengeLocalizations commonI18n = ChallengeLocalizations(Locale('en'));

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

    Challenge c = verify(challengeService.save(captureAny)).captured.single;
    expect(c.name, 'Test Challenge');
    expect(c.reward, 6);
    expect(c.createdAt, isNotNull);
    expect(c.createdAt.day, DateTime.now().day);
    expect(c.dueAt, dateDue);
    expect(c.latestAt, dateLatest);
  });

}