import 'package:flutter/material.dart';
import 'package:flutterapp/app_config.dart';
import 'package:flutterapp/container/app_context.dart';
import 'package:flutterapp/home/page/challenge_home_page.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppContext _context = buildContext();

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