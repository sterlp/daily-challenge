
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/app_config.dart';
import 'package:flutterapp/container/app_context.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

MaterialApp createTestApp(Widget widget) {
  return MaterialApp(title: 'Test App', home: widget);
}

Future<MaterialApp> pumpTestApp(WidgetTester tester, Widget widget) async {
  var app = createTestApp(widget);
  await tester.pumpWidget(app);
  return app;
}

AppContext testContainer() {
  sqfliteFfiInit();
  final db = databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  return buildContext(db);
}