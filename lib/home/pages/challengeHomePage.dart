import 'package:flutter/material.dart';
import 'package:flutterapp/challengelist/dao/challengeDao.dart';
import 'package:flutterapp/challengelist/models/challengeModel.dart';
import 'package:flutterapp/challengelist/pages/challengeListPage.dart';
import 'package:flutterapp/challengelist/pages/challengePage.dart';
import 'package:flutterapp/challengelist/pages/challenge_month_overview_page.dart';
import 'package:flutterapp/challengelist/services/challengeService.dart';
import 'package:flutterapp/container/container.dart';
import 'package:flutterapp/db/dbProvider.dart';
import 'package:flutterapp/db/testData.dart';
import 'package:flutterapp/home/views/totalPointView.dart';

class ChallengeHomePage extends StatefulWidget {

  final DiContainer _container = new DiContainer()
    ..add(DbProvider())
    ..addFactory((rattlinger) => ChallengeDao(rattlinger.get<DbProvider>().db))
    ..addFactory((rattlinger) => ChallengeService(rattlinger.get<ChallengeDao>()))
    ..addFactory((rattlinger) => TestData(rattlinger.get<ChallengeService>()));

  ChallengeHomePage({Key key}) : super(key: key);

  @override
  _ChallengeHomePageState createState() => _ChallengeHomePageState(_container);
}

class _ChallengeHomePageState extends State<ChallengeHomePage> {
  int _page = 0;
  final PageController _pagesController = PageController(initialPage: 0);

  final DiContainer _container;
  final ChallengeService _challengeService;

  _ChallengeHomePageState._(this._container, this._challengeService);
  factory _ChallengeHomePageState(DiContainer container) {
    var c = container.get<ChallengeService>();
    c.getTotal(); // load the total
    return new _ChallengeHomePageState._(container, c);
  }

  @override
  void dispose() {
    super.dispose();
    _container.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pagesController,
        scrollDirection: Axis.horizontal,
        children: [
          ChallengeListPage(_container),
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
                      ChallengePage(challenge: Challenge(), challengeService: _challengeService)
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
                child: TotalPointView(_challengeService.totalPointsStream),
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