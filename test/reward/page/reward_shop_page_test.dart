import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/reward/model/reward_model.dart';
import 'package:flutterapp/reward/page/reward_shop_page.dart';
import '../../mock_appcontext.dart';
import '../../test_helper.dart';

void main() {

  AppContextMock appContextMock;

  setUp(() async {
    appContextMock = AppContextMock();
  });


  testWidgets('RewardShopPage no rewards', (WidgetTester tester) async {
    await pumpTestApp(tester, RewardShopPage(), appContextMock.appContext);
    await tester.pumpAndSettle();
    expect(find.text('No rewards created yet'), findsOneWidget);
  });

  testWidgets('RewardShopPage reward button test', (WidgetTester tester) async {
    appContextMock.credits.value = 6;
    appContextMock.rewards.add(Reward()
      ..name = 'Schoki'
      ..cost = 5
    );
    appContextMock.rewards.add(Reward()
        ..name = 'Bier'
        ..cost = 10
    );
    await pumpTestApp(tester, RewardShopPage(), appContextMock.appContext);
    await tester.pumpAndSettle();
    expect(find.text('Bier'), findsOneWidget);
    expect(find.text('Schoki'), findsOneWidget);

    expect(tester.widget<RaisedButton>(find.byType(RaisedButton).first).enabled, isTrue);
    expect(tester.widget<RaisedButton>(find.byType(RaisedButton).last).enabled, isFalse);

    appContextMock.credits.value = 20;
    await tester.pumpAndSettle();
    expect(tester.widget<RaisedButton>(find.byType(RaisedButton).last).enabled, isTrue);
  });
}

