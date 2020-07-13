import 'package:flutter/material.dart';
import 'package:flutterapp/challengelist/models/challenge_model.dart';
import 'package:flutterapp/challengelist/pages/challenge_list_page.dart';
import 'package:flutterapp/challengelist/pages/challenge_page.dart';
import 'package:flutterapp/challengelist/pages/challenge_month_overview_page.dart';
import 'package:flutterapp/challengelist/services/challenge_service.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
import 'package:flutterapp/home/widgets/total_points_widget.dart';

class ChallengeHomePage extends StatefulWidget {

  ChallengeHomePage({Key key}) : super(key: key);

  @override
  _ChallengeHomePageState createState() => _ChallengeHomePageState();
}

class _ChallengeHomePageState extends State<ChallengeHomePage> {
  int _page = 0;
  final PageController _pagesController = PageController(initialPage: 0);

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
          ChallengeMonthOverviewPage()
        ],
        physics: NeverScrollableScrollPhysics(), // Comment this if you need to use Swipe.
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute<Challenge>(
              builder: (BuildContext context) =>
                ChallengePage(challenge: Challenge())
            )
          );
        },
        icon: Icon(Icons.add),
        label: Text('Create challenge'),
        // backgroundColor: Colors.blueGrey,
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
              onPressed: () {
                _pagesController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.ease);
                setState(() => _page = 0);
              }
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(2, 32, 2, 12),
                child: TotalPointsWidget(_challengeService.totalPointsStream),
            ),
            IconButton(
              iconSize: 30.0,
              // padding: EdgeInsets.only(left: 28.0),
              icon: Icon(Icons.view_week, color: _page == 1 ? Colors.blue : null),
              onPressed: () {
                _pagesController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.ease);
                setState(() => _page = 1);
              }
            ),
          ],
        ),
      ),
    );
  }
}