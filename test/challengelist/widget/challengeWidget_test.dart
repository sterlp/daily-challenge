import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/challengelist/widget/challenge_widget.dart';
import 'package:challengeapp/common/common_types.dart';

import '../../mock_appcontext.dart';
import '../../test_helper.dart';

void main() {
  AppContextMock appContextMock;

  setUp(() async {
    appContextMock = AppContextMock();
  });

  testWidgets('Show simple challenge', (WidgetTester tester) async {
    // Create the widget by telling the tester to build it.
    Challenge c = Challenge.of('test challenge 1', null, 77);
    await pumpTestApp(tester, Card(
      child: ListView(
        children: [
            ChallengeWidget(c),
            ChallengeWidget(Challenge.of('test challenge 2'))
          ]
        ),
      ),
      appContextMock.appContext
    );
    await tester.pumpAndSettle();

    expect(find.text(c.name), findsOneWidget);
    expect(find.text('77'), findsOneWidget);
    
    expect(find.text('test challenge 2'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    expect(find.byIcon(MyStyle.ICON_PENDING_CHALLENGE), findsNWidgets(2));
  });
}