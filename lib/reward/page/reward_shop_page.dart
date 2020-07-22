import 'package:flutter/material.dart';
import 'package:flutterapp/credit/service/credit_service.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
import 'package:flutterapp/home/widget/loading_widget.dart';
import 'package:flutterapp/home/widget/total_points_widget.dart';
import 'package:flutterapp/log/logger.dart';
import 'package:flutterapp/reward/model/reward_model.dart';
import 'package:flutterapp/reward/page/reward_page.dart';
import 'package:flutterapp/reward/service/reward_service.dart';
import 'package:flutterapp/reward/widget/reward_card_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RewardShopPage extends StatefulWidget {
  RewardShopPage({Key key}) : super(key: key);

  @override
  _RewardShopPageState createState() => _RewardShopPageState();
}

class _RewardShopPageState extends State<RewardShopPage> {
  static final Logger _log = LoggerFactory.get<RewardShopPage>();

  RewardService _rewardService;
  CreditService _creditService;

  Future<List<Reward>> _rewards;
  ValueNotifier<int> _totalCredit;

  void _reload() {
    _rewards = _creditService.credit.then((value) {
      return _rewardService.listRewards(999, 0);
    });
    setState(() {});
  }

  void _buyReward(Reward r, BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyText1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buy Reward'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                    style: bodyStyle,
                    text: 'Do you really want to spend ',
                    children: [
                      WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(MdiIcons.cashMultiple, color: Colors.green, size: bodyStyle.fontSize)),
                      ),
                      TextSpan(text: r.cost.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' for '),
                      TextSpan(text: r.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '?'),
                    ]
                ),
              ),
              RichText(
                text: TextSpan(
                  style: bodyStyle,
                  text: 'You still have ',
                  children: [
                    WidgetSpan(
                      child: Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(Icons.star, color: Colors.amber, size: bodyStyle.fontSize)),
                    ),
                    TextSpan(text: _totalCredit.value.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' left.'),
                  ]
                ),
              ),
            ]
          ),
          actions: <Widget>[
            FlatButton(child: const Text('CANCEL'), onPressed: () => Navigator.of(context).pop()),
            FlatButton(child: const Text('CONFIRM'), onPressed: () {
              _rewardService.buyReward(r);
              Navigator.of(context).pop();
            }),
          ],
        );
      },
    );
    // _rewardService.buyReward(r).then((v) => _reload());
  }

  void _deleteReward(Reward r, BuildContext context) {
    _log.debug('delete reward $r');
    _rewardService.deleteReward(r).then((v) => _reload());
  }

  @override
  Widget build(BuildContext context) {
    _log.debug('build ...');
    _rewardService ??= AppStateWidget.of(context).get<RewardService>();
    _creditService ??= AppStateWidget.of(context).get<CreditService>();
    _totalCredit ??= _creditService.creditNotifier;

    _rewards ??= _creditService.credit.then((value) {
      return _rewardService.listRewards(999, 0);
    });

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
          var result = await Navigator.push(context, MaterialPageRoute<Reward>(builder: (BuildContext context) => RewardPage(reward: Reward())));
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
    return ListView(
        padding: const EdgeInsets.all(8.0),
        children:
            rewards.map((e) => RewardCardWidget(e, _totalCredit.value, _buyReward, _deleteReward, key: ValueKey(e))).toList());
  }

  Widget _buildEmptyStore(BuildContext context) {
    return Center(child: Text('No rewards created yet', style: Theme.of(context).textTheme.headline5));
  }
}
