import 'package:flutter/material.dart';
import 'package:flutterapp/challengelist/dao/challengeDao.dart';
import 'package:flutterapp/challengelist/models/challengeModel.dart';
import 'package:flutterapp/challengelist/pages/challengeListPage.dart';
import 'package:flutterapp/challengelist/pages/challengePage.dart';
import 'package:flutterapp/challengelist/services/challengeService.dart';
import 'package:flutterapp/db/dbProvider.dart';
import 'package:flutterapp/db/testData.dart';
import 'package:flutterapp/util/container.dart';

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
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _challengeService.totalPointsStream,
      builder: (context, snapshot) {
        return Scaffold(
          body: PageView(
            controller: _pagesController,
            children: [
              ChallengeListPage(_container)
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
                  icon: Icon(Icons.calendar_today, color: Colors.blue),
                  onPressed: () {},
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(2, 32, 2, 12),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.star, color: Colors.amber),
                        Text(snapshot.data == null ? '0' : snapshot.data.toString(),
                            textScaleFactor: 1.2)
                      ],
                    )
                ),

                IconButton(
                  iconSize: 30.0,
                  // padding: EdgeInsets.only(left: 28.0),
                  icon: Icon(Icons.view_week),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}