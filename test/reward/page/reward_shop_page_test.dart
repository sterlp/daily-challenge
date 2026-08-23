import 'package:challengeapp/reward/model/reward_model.dart';
import 'package:challengeapp/reward/page/reward_shop_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mock_app_context.dart';
import '../../test_helper.dart';

void main() {
  late AppContextMock appContextMock;

  setUp(() {
    appContextMock = AppContextMock();
  });

  testWidgets('RewardShopPage no rewards', (WidgetTester tester) async {
    await pumpTestApp(
      tester,
      const RewardShopPage(),
      appContextMock.appContext,
    );
    await tester.pumpAndSettle();
    expect(find.text('No rewards created yet'), findsOneWidget);
  });

  testWidgets('RewardShopPage reward button test', (WidgetTester tester) async {
    appContextMock.credits.value = 6;
    appContextMock.rewards.add(
      Reward()
        ..name = 'Schoki'
        ..cost = 5,
    );
    appContextMock.rewards.add(
      Reward()
        ..name = 'Bier'
        ..cost = 10,
    );
    await pumpTestApp(
      tester,
      const RewardShopPage(),
      appContextMock.appContext,
    );
    await tester.pumpAndSettle();
    expect(find.text('Bier'), findsOneWidget);
    expect(find.text('Schoki'), findsOneWidget);

    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton).first).enabled,
      isTrue,
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton).last).enabled,
      isFalse,
    );

    appContextMock.credits.value = 20;
    await tester.pumpAndSettle();
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton).last).enabled,
      isTrue,
    );
  });
}
