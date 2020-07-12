import 'package:flutter/material.dart';

class ChallengeMonthOverviewPage extends StatefulWidget {
  ChallengeMonthOverviewPage({Key key}) : super(key: key);

  @override
  _ChallengeMonthOverviewPageState createState() =>
      _ChallengeMonthOverviewPageState();
}

class _ChallengeMonthOverviewPageState
    extends State<ChallengeMonthOverviewPage> {
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