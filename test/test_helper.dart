import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/app_config.dart';
import 'package:flutterapp/container/app_context.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

MaterialApp createTestApp(Widget widget, [AppContext appContext]) {
  if (appContext == null) return MaterialApp(home: widget);
  else return MaterialApp(
      home: AppStateWidget(
        context: appContext,
        child: widget,
      )
    );
}

Future<MaterialApp> pumpTestApp(WidgetTester tester, Widget widget, [AppContext appContext]) async {
  var app = createTestApp(widget, appContext);
  await tester.pumpWidget(app);
  return app;
}

AppContext testContainer() {
  sqfliteFfiInit();
  final db = databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  return buildContext(db);
}

