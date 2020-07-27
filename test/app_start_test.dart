import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/main.dart';
import 'mock_appcontext.dart';

void main() async {
  AppContextMock appContextMock;

  setUp(() async {
    appContextMock = AppContextMock();
  });

  testWidgets('Challenge App start test', (WidgetTester tester) async {
    // avoid block of the main test thread
      final myApp = MyApp(container: appContextMock.appContext);
      await tester.pumpWidget(myApp);
      await tester.pumpAndSettle(); // yeah we have now to wait for flutter to load i18n resources, this is of course not documented

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
}
