import 'package:flutter/material.dart';
import 'package:challengeapp/challengelist/page/challenge_list_page.dart';
import 'package:challengeapp/history/page/history_page.dart';
import 'package:challengeapp/i18n/challenge_localization_delegate.dart';
import 'package:challengeapp/reward/page/reward_shop_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ChallengeHomePage extends StatefulWidget {

  ChallengeHomePage({Key key}) : super(key: key);

  @override
  _ChallengeHomePageState createState() => _ChallengeHomePageState();
}

class _ChallengeHomePageState extends State<ChallengeHomePage> {
  @override
  Widget build(BuildContext context) {
    final i18n = Localizations.of<ChallengeLocalizations>(context, ChallengeLocalizations);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(MdiIcons.calendarMultipleCheck), text: i18n.challengeTab),
              Tab(icon: Icon(MdiIcons.trophy), text: i18n.rewardTab),
              Tab(icon: Icon(Icons.access_time), text: i18n.historyTab),
            ],
          ),
          title: Text(i18n.appName),
        ),
        body: TabBarView(
          children: [
            ChallengeListPage(),
            RewardShopPage(),
            HistoryPage()
          ],
        )
      ),
    );
  }
}