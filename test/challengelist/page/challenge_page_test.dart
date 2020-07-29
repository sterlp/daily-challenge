
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/challengelist/i18n/challengelist_localization.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/challengelist/page/challenge_page.dart';

import '../../mock_appcontext.dart';
import '../../test_helper.dart';

void main() {
  AppContextMock appContextMock;
  ChallengeListLocalizations i18n = ChallengeListLocalizations(Locale('en'));
  setUp(() async {
    appContextMock = AppContextMock();
  });

  /* TEST broken because of https://github.com/AbdulRahmanAlHamali/flutter_typeahead/issues/155
  testWidgets('RewardShopPage no rewards', (WidgetTester tester) async {
    await pumpTestApp(tester, ChallengePage(challenge: Challenge()), appContextMock.appContext);
    await tester.pumpAndSettle();

    expect(find.text(i18n.createChallengeHeader), findsOneWidget);
  });
*/

}