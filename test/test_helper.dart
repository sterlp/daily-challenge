import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:challengeapp/app_config.dart';
import 'package:challengeapp/home/state/app_state_widget.dart';
import 'package:challengeapp/i18n/app_localizations_delegate.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

MaterialApp createTestApp(Widget widget, [AppContainer appContext]) {
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

Future<MaterialApp> pumpTestApp(WidgetTester tester, Widget widget, [AppContainer appContext]) async {
  var app = createTestApp(widget, appContext);
  await tester.pumpWidget(app);
  return app;
}

AppContainer testContainer() {
  sqfliteFfiInit();
  final db = databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  return buildContext(db);
}

