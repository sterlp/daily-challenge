import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/home/widgets/total_points_widget.dart';
import 'package:flutterapp/util/model/observable_model.dart';


import '../../test_helper.dart';

void main() {
  testWidgets('Show simple challenge', (WidgetTester tester) async {
    final ObservableModel<int> _model = ObservableModel<int>();

    await pumpTestApp(tester, TotalPointsWidget(_model));
    await tester.pump();

    // loading should be shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // if we add a number
    _model.value = 7;
    await tester.pumpAndSettle();
    // we should see it
    expect(find.text('7'), findsOneWidget);

    _model.close();
  });
}