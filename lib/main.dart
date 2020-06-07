import 'package:flutter/material.dart';
import 'package:flutterapp/challengelist/pages/challengeListPage.dart';
import 'package:flutterapp/home/pages/challengeHomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: ChallengeHomePage()
    );
  }
}