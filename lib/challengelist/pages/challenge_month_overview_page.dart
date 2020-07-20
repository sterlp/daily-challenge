import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutterapp/challengelist/models/challenge_model.dart';
import 'package:flutterapp/challengelist/services/challenge_service.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';

class ChallengeMonthOverviewPage extends StatefulWidget {
  ChallengeMonthOverviewPage({Key key}) : super(key: key);

  @override
  _ChallengeMonthOverviewPageState createState() =>
      _ChallengeMonthOverviewPageState();
}

class _ChallengeMonthOverviewPageState extends State<ChallengeMonthOverviewPage> {
  ChallengeService _challengeService;
  DateTime _selectedDay = DateTime.now();
  final List<Challenge> _challenges = [];

  // InheritedWidget doesn't work with initState, Flutter isn't consistent here.
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _challengeService = AppStateWidget.of(context).get<ChallengeService>();
      _reload();
    });
  }
  Future<void> _reload() async {
    Timeline.startSync('ChallengeMonthOverviewPage._reload()');

    Timeline.finishSync();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kick your butt today'),
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () async {},
            icon: Icon(Icons.arrow_drop_down), label: Text('Foo'))
        ],
      ),
      body: Text('Hello'),
    );
  }
}