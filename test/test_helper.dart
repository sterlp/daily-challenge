import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:challengeapp/app_config.dart';
import 'package:challengeapp/container/app_context.dart';
import 'package:challengeapp/home/state/app_state_widget.dart';
import 'package:challengeapp/i18n/app_localizations_delegate.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

MaterialApp createTestApp(Widget widget, [AppContext appContext]) {
  if (appContext == null) return MaterialApp(
      localizationsDelegates: AppLocalizationsDelegate.delegates,
      supportedLocales: AppLocalizationsDelegate.locales,
      home: widget
  );
  else return MaterialApp(
      localizationsDelegates: AppLocalizationsDelegate.delegates,
      supportedLocales: AppLocalizationsDelegate.locales,
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

