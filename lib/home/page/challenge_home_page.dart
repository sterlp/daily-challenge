import 'package:flutter/material.dart';
import 'package:flutterapp/challengelist/page/challenge_list_page.dart';
import 'package:flutterapp/i18n/challenge_localization_delegate.dart';
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
    final i18n = Localizations.of<ChallengeLocalizations>(context, ChallengeLocalizations);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: i18n.challengeTab),
              Tab(icon: Icon(MdiIcons.trophy), text: i18n.rewardTab),
            ],
          ),
          title: Text(i18n.appName),
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