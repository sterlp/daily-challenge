import 'package:challengeapp/challengelist/dao/challenge_dao.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/challengelist/service/challenge_service.dart';
import 'package:challengeapp/main.dart';
import 'package:mockito/mockito.dart';

import '../../mock_appcontext.dart';

void main() {
  AppContextMock appContextMock;

  setUp(() async {
    appContextMock = AppContextMock();
  });

  // TEST broken because of https://github.com/AbdulRahmanAlHamali/flutter_typeahead/issues/155
  testWidgets('Simple show challenges', (WidgetTester tester) async {
    final challengeService = appContextMock.appContext.get<ChallengeService>();

    when(challengeService.loadByDate(any, true)).thenAnswer((realInvocation) =>
      SynchronousFuture([
        Challenge.full('C1')..reward = 8,
        Challenge.full('C2', DateTime.now().add(const Duration(days: -1))),
        Challenge.full('C3 Failed', null, ChallengeStatus.failed),
        Challenge.full('C4 Done', null, ChallengeStatus.done),
      ])
    );

    final myApp = MyApp(container: appContextMock.appContext);
    await tester.pumpWidget(myApp);
    await tester.pumpAndSettle(); // yeah we have now to wait for flutter to load i18n resources, this is of course not documented

    expect(find.text('C1'), findsOneWidget);
    expect(find.text('C2'), findsOneWidget);
    expect(find.text('C3 Failed'), findsOneWidget);
    expect(find.text('C4 Done'), findsOneWidget);

    verify(challengeService.loadByDate(any, true)).called(1);
    verifyNever(challengeService.failOverDue(any));
  });

}