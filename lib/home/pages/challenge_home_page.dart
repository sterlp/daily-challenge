import 'package:flutter/material.dart';
import 'package:flutterapp/challengelist/pages/challenge_list_page.dart';
import 'package:flutterapp/challengelist/services/challenge_service.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
import 'package:flutterapp/home/widgets/total_points_widget.dart';
import 'package:flutterapp/reward/page/reward_shop_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ChallengeHomePage extends StatefulWidget {

  ChallengeHomePage({Key key}) : super(key: key);

  @override
  _ChallengeHomePageState createState() => _ChallengeHomePageState();
}

class _ChallengeHomePageState extends State<ChallengeHomePage> {
  int _page = 0;
  final PageController _pagesController = PageController(initialPage: 0);

  _showPage(int index) {
    if (_page != index) {
      _pagesController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
      setState(() => _page = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _container = AppStateWidget.of(context);
    final _challengeService = _container.get<ChallengeService>();

    return Scaffold(
      body: PageView(
        controller: _pagesController,
        scrollDirection: Axis.horizontal,
        children: [
          ChallengeListPage(),
          RewardShopPage()
        ],
        physics: NeverScrollableScrollPhysics(), // Comment this if you need to use Swipe.
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        // shape: CircularNotchedRectangle(),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              iconSize: 30.0,
              // padding: EdgeInsets.only(left: 28.0),
              icon: Icon(Icons.calendar_today, color: _page == 0 ? Colors.blue : null),
              onPressed: () => _showPage(0)
            ),
            TotalPointsWidget(_challengeService.totalPointsStream),
            IconButton(
              iconSize: 30.0,
              // padding: EdgeInsets.only(left: 28.0),
              icon: Icon(MdiIcons.trophy, color: _page == 1 ? Colors.blue : null),
              onPressed: () =>  _showPage(1)
            ),
          ],
        ),
      ),
    );
  }
}