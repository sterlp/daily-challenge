
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

MaterialApp createTestApp(Widget widget) {
  return MaterialApp(title: 'Test App', home: widget);
}

Future<MaterialApp> pumpTestApp(WidgetTester tester, Widget widget) async {
  var app = createTestApp(widget);
  await tester.pumpWidget(app);
  return app;
}