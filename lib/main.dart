import 'package:flutter/material.dart';
import 'package:flutterapp/challengelist/dao/challenge_dao.dart';
import 'package:flutterapp/challengelist/services/challenge_service.dart';
import 'package:flutterapp/container/app_context.dart';
import 'package:flutterapp/db/db_provider.dart';
import 'package:flutterapp/db/test_data.dart';
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