import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/container/app_context.dart';
import 'package:flutterapp/db/db_provider.dart';
import 'package:flutterapp/main.dart';

import 'test_helper.dart';

void main() async {
  AppContext appContext;
  setUp(() async {
    appContext = testContainer();
    await appContext.get<DbProvider>().db;
  });

  testWidgets('Challenge App start test', (WidgetTester tester) async {
    // avoid block of the main test thread
    await tester.runAsync(() async {
      final myApp = MyApp(container: appContext);
      await tester.pumpWidget(myApp);

      // first we should have the loading DB spinner ...
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Building DB ...'), findsOneWidget);
      // after the DB was build
      await appContext.get<DbProvider>().db;
      await tester.pumpWidget(myApp);

      // the main page should be shown
      expect(find.text('Challenge Yourself'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // if we click +
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // we should be able to create a challenge
      expect(find.text('Create Challenge'), findsOneWidget);
      expect(find.text('CREATE'), findsOneWidget);
    });

  });
}
