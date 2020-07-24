import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/challengelist/widget/challenge_widget.dart';

void main() {
  testWidgets('Show simple challenge', (WidgetTester tester) async {
    // Create the widget by telling the tester to build it.
    Challenge c = Challenge.withName('test challenge 1')
      ..reward = 77;
    await tester.pumpWidget(MaterialApp(
        home: Card(child: ListView(
          children: [
              ChallengeWidget(challenge: c),
              ChallengeWidget(challenge: Challenge.withName('test challenge 2'))
            ]
          )
        )
      )
    );
    await tester.pumpAndSettle();

    expect(find.text(c.name), findsOneWidget);
    expect(find.text('77'), findsOneWidget);
    
    expect(find.text('test challenge 2'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    expect(find.byIcon(Icons.stars), findsNWidgets(2));
  });
}