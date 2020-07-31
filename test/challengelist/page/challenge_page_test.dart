
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/challengelist/i18n/challengelist_localization.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/challengelist/page/challenge_page.dart';
import 'package:flutterapp/challengelist/service/challenge_service.dart';
import 'package:flutterapp/i18n/challenge_localization_delegate.dart';
import 'package:mockito/mockito.dart';

import '../../mock_appcontext.dart';
import '../../test_helper.dart';

void main() {
  AppContextMock appContextMock;
  final ChallengeListLocalizations i18n = ChallengeListLocalizations(Locale('en'));
  final ChallengeLocalizations commonI18n = ChallengeLocalizations(Locale('en'));

  setUp(() async {
    appContextMock = AppContextMock();
  });

  // TEST broken because of https://github.com/AbdulRahmanAlHamali/flutter_typeahead/issues/155
  testWidgets('RewardShopPage no rewards', (WidgetTester tester) async {
    final challengeService = appContextMock.appContext.get<ChallengeService>();
    final DateTime now = DateTime.now();
    final dateDue = DateTime(now.year, now.month, 11);
    final dateLatest = DateTime(now.year, now.month, 15);
    final startChallenge = Challenge()
      ..dueAt = DateTime(now.year, now.month, 10)
      ..latestAt = null;

    // we use a challenge with the day from yesterday:
    await pumpTestApp(tester, ChallengePage(challenge: startChallenge), appContextMock.appContext);
    await tester.pumpAndSettle();

    expect(find.text(i18n.createChallengeHeader), findsOneWidget);
    // the day should be shown
    expect(find.text(commonI18n.formatDate(startChallenge.dueAt)), findsOneWidget);

    await tester.enterText(find.byKey(ValueKey('challenge_name')), 'Test Challenge');
    await tester.pumpAndSettle();

    // select a due at date
    await tester.tap(find.text(i18n.challengeDueAt.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(dateDue.day.toString()));
    await tester.pumpAndSettle();
    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();
    expect(find.text(commonI18n.formatDate(dateDue)), findsOneWidget);
    expect(find.text(commonI18n.formatDate(startChallenge.dueAt)), findsNothing);

    // select latest date
    await tester.tap(find.text(i18n.challengeLatestAt.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(dateLatest.day.toString()));
    await tester.pumpAndSettle();
    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();
    expect(find.text(commonI18n.formatDate(dateLatest)), findsOneWidget);

    // enter reward
    await tester.enterText(find.byKey(ValueKey('challenge_reward')), '6');
    await tester.tap(find.text(commonI18n.buttonCreate));
    await tester.pumpAndSettle();

    verify(challengeService.save(any)).called(1);

    Challenge c = verify(challengeService.save(any)).captured.single;
    expect(c.name, 'Test Challenge');

  });

}