import 'package:flutter/material.dart';
import 'package:flutterapp/challengelist/dao/challengeDao.dart';
import 'package:flutterapp/challengelist/services/challengeService.dart';
import 'package:flutterapp/container/app_context.dart';
import 'package:flutterapp/db/dbProvider.dart';
import 'package:flutterapp/db/testData.dart';
import 'package:flutterapp/home/pages/challengeHomePage.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppContext _context = new AppContext()
    // lazy init of the beans to give Flutter the time to start before we init the DB, otherwise we face:
    // Unhandled Exception: ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized.
    ..addFactory((_) => DbProvider())
    ..addFactory((rattlinger) => ChallengeDao(rattlinger.get<DbProvider>().db))
    ..addFactory((rattlinger) => ChallengeService(rattlinger.get<ChallengeDao>()))
    ..addFactory((rattlinger) => TestData(rattlinger.get<ChallengeService>()));

  @override
  Widget build(BuildContext context) {
    // wrap the MaterialApp to ensure that all pages opened with the navigator also see the AppStateWidget
    return AppStateWidget(
      context: _context,
      child: MaterialApp(
        theme: ThemeData(),
        home: ChallengeHomePage()
      ),
    );
  }
}