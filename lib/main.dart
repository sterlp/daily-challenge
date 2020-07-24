import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterapp/app_config.dart';
import 'package:flutterapp/container/app_context.dart';
import 'package:flutterapp/db/db_provider.dart';
import 'package:flutterapp/home/page/challenge_home_page.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
import 'package:flutterapp/home/widget/loading_widget.dart';
import 'package:flutterapp/log/logger.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final Logger _log = LoggerFactory.get<MyApp>();
  final AppContext appContext;

  MyApp({Key key, AppContext container}) :
        appContext = container == null ? buildContext() : container,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // wrap the MaterialApp to ensure that all pages opened with the navigator also see the AppStateWidget
    var darkThemeData = ThemeData.dark();
    return AppStateWidget(
      context: appContext,
      child: MaterialApp(
        theme:  darkThemeData.copyWith(
          accentColor: Colors.blue,
          indicatorColor: Colors.blue,
          textSelectionHandleColor: Colors.blue,
          toggleableActiveColor: Colors.green,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.blue,
          ),

        ),
        home: FutureBuilder(
          future: appContext.get<DbProvider>().db,
          builder: (context, snapshot) {
            _log.debug('build FutureBuilder ${snapshot.hasData} -> ${snapshot.data}');
            if (snapshot.hasData) {
              return ChallengeHomePage();
            } else {
              return Scaffold(body: LoadingWidget(caption: 'Building DB ...'));
            }
          }
        )
      ),
    );
  }
}