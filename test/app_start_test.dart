import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/main.dart';

void main() {
  testWidgets('Challenge App start test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Challenges'), findsOneWidget);


    // Tap the '+' icon and switch page.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify that the new page is shown
    expect(find.text('Create a new challenge'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);
  });
}
