import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutterapp/challengelist/service/challenge_service.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
import 'package:flutterapp/home/widget/loading_widget.dart';
import 'package:flutterapp/home/widget/total_points_widget.dart';
import 'package:flutterapp/log/logger.dart';
import 'package:flutterapp/reward/model/reward_model.dart';
import 'package:flutterapp/reward/page/reward_page.dart';
import 'package:flutterapp/reward/service/reward_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RewardShopPage extends StatefulWidget {
  RewardShopPage({Key key}) : super(key: key);

  @override
  _RewardShopPageState createState() => _RewardShopPageState();
}

class _RewardShopPageState extends State<RewardShopPage> {
  static final Logger _log = LoggerFactory.get<RewardShopPage>();

  RewardService _rewardService;
  Future<List<Reward>> _rewards;
  ValueNotifier<int> _totalCredit;

  void _reload() async {
    setState(() {
      _rewards = _rewardService.listRewards(999, 0);
    });
  }

  void _buyReward(Reward r) async {
    _log.debug('buy reward $r');
  }

  @override
  Widget build(BuildContext context) {
    if (_rewardService == null) _rewardService = AppStateWidget.of(context).get<RewardService>();
    if (_rewards == null) _rewards = AppStateWidget.of(context).get<ChallengeService>().calcTotal().then((value) {
      return _rewardService.listRewards(999, 0);
    });
    if (_totalCredit == null) _totalCredit = AppStateWidget.of(context).get<ChallengeService>().totalPoints;

    return Scaffold(
      body: FutureBuilder<List<Reward>>(
        future: _rewards,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.isEmpty) {
            return _buildEmptyStore(context);
          } else if (snapshot.hasData) {
            return _buildResult(context, snapshot.data);
          } else {
            return LoadingWidget();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
              context,
              MaterialPageRoute<Reward>(builder: (BuildContext context) => RewardPage(reward: Reward()))
          );
          _log.debug('RewardPage returned with $result');
          if (result != null) _reload();
        },
        tooltip: 'New Reward',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: <Widget>[
              Spacer(),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TotalPointsWidget(_totalCredit),
              )
            ],
          )
      )
    );
  }

  Widget _buildResult(BuildContext context, List<Reward> rewards) {
    _log.debug('_buildResult -> ${_totalCredit.value}');
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children:
        rewards.map((e) =>
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: SizedBox.fromSize(
                    size: Size(56, 56), // button width and height
                      child: ClipOval(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(MdiIcons.cashMultiple, color: Colors.green,), // icon
                            Text(e.cost.toString(), style: TextStyle(color: Colors.green), textScaleFactor: 1.2), // text
                          ],
                        ),
                      ),
                    ),
                  ),
                  title: Text(e.name),
                  trailing: Icon(MdiIcons.trophy, color: Colors.amber),
                ),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: const Text('REWARD MYSELF'),
                      onPressed: (e.cost <= _totalCredit.value ? () => _buyReward(e) : null)
                    ),
                  ],
                )
              ]
            ),
          )
        ).toList()
    );
  }

  Widget _buildEmptyStore(BuildContext context) {
    return Center(child: Text('No rewards created yet', style: Theme.of(context).textTheme.headline5));
  }
}