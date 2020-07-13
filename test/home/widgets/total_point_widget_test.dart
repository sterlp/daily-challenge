import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/home/widgets/total_points_widget.dart';


import '../../test_helper.dart';

void main() {
  testWidgets('Show simple challenge', (WidgetTester tester) async {
    final StreamController<int> _controller = StreamController<int>();

    await pumpTestApp(tester, TotalPointsWidget(_controller.stream));
    await tester.pump();

    // loading should be shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // if we add a number
    _controller.sink.add(7);
    await tester.pumpAndSettle();
    // we should see it
    expect(find.text('7'), findsOneWidget);

    _controller.close();
  });
}