import 'package:flutter/material.dart';
import 'package:flutterapp/challengelist/pages/challenge_list_page.dart';
import 'package:flutterapp/reward/page/reward_shop_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ChallengeHomePage extends StatefulWidget {

  ChallengeHomePage({Key key}) : super(key: key);

  @override
  _ChallengeHomePageState createState() => _ChallengeHomePageState();
}

class _ChallengeHomePageState extends State<ChallengeHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: 'Challenges',),
              Tab(icon: Icon(MdiIcons.trophy), text: 'Rewards'),
            ],
          ),
          title: Text('Kick your butt today'),
        ),
          body: TabBarView(
            children: [
              ChallengeListPage(),
              RewardShopPage()
            ],
          )
      ),
    );
  }
}