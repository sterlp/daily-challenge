import 'package:challengeapp/home/widget/total_points_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helper.dart';

void main() {
  testWidgets('Show simple challenge', (WidgetTester tester) async {
    final ValueNotifier<int> model = ValueNotifier<int>(0);

    await pumpTestApp(tester, TotalPointsWidget(model));
    await tester.pump();

    // initial value should be shown
    expect(find.text('0'), findsOneWidget);

    // if we add a number
    model.value = 7;
    await tester.pumpAndSettle();
    // we should see it
    expect(find.text('7'), findsOneWidget);
  });
}
