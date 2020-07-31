import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/challengelist/i18n/challengelist_localization.dart';
import 'package:flutterapp/i18n/challenge_localization_delegate.dart';
import 'package:flutterapp/main.dart';
import 'mock_appcontext.dart';

void main() async {
  AppContextMock appContextMock;
  final ChallengeLocalizations i18n = ChallengeLocalizations(Locale('en'));
  final ChallengeListLocalizations challengeI18n = ChallengeListLocalizations(Locale('en'));

  setUp(() async {
    appContextMock = AppContextMock();
  });

  testWidgets('Challenge App start test', (WidgetTester tester) async {
      final myApp = MyApp(container: appContextMock.appContext);
      await tester.pumpWidget(myApp);
      await tester.pumpAndSettle(); // yeah we have now to wait for flutter to load i18n resources, this is of course not documented

      // the main page should be shown
      expect(find.text(i18n.appName), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // if we click + we we want to see the challenge page
      await tester.tap(find.text(challengeI18n.newChallengeButton));
      await tester.pumpAndSettle();

      // we should be able to create a challenge
      expect(find.text(challengeI18n.createChallengeHeader), findsOneWidget);
      expect(find.text(i18n.buttonCreate), findsOneWidget);
  });
}
