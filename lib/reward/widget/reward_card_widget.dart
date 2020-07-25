import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterapp/common/common_types.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
import 'package:flutterapp/log/logger.dart';
import 'package:flutterapp/reward/model/bought_reward_model.dart';
import 'package:flutterapp/reward/model/reward_model.dart';
import 'package:flutterapp/reward/page/reward_page.dart';
import 'package:flutterapp/reward/service/reward_service.dart';
import 'package:flutterapp/reward/widget/buy_reward_dialog.dart';


typedef RewardCallback = void Function(Reward reward, BuildContext context);

class RewardCardWidget extends StatefulWidget {
  final Reward _reward;
  final ValueNotifier _credit;
  final RewardCallback deleteRewardCallback;

  RewardCardWidget(this._reward, this._credit, this.deleteRewardCallback, {Key key}) : super(key: key);

  @override
  _RewardCardWidgetState createState() => _RewardCardWidgetState();
}

class _RewardCardWidgetState extends State<RewardCardWidget> {
  static final _log = LoggerFactory.get<RewardCardWidget>();
  static const ACTION_PADDING = EdgeInsets.all(4.0);

  RewardService _rewardService;
  BoughtReward _boughtReward;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rewardService ??= AppStateWidget.of(context).get<RewardService>();
    _loadBoughtReward();
  }

  void _loadBoughtReward() async {
    var boughtReward = await _rewardService.getLastBoughtRewardByRewardId(widget._reward.id);
    if (boughtReward != null && boughtReward != _boughtReward) {
      setState(() => _boughtReward = boughtReward);
    }
  }

  void _buyReward() async {
    bool buy = await showBuyRewardDialog(context, widget._reward, widget._credit.value);
    if (buy) {
      _boughtReward = await _rewardService.buyReward(widget._reward);
      setState(() {});
    }
  }

  void _editReward() async {
    var result = await Navigator.push(
        context, MaterialPageRoute<Reward>(builder: (BuildContext context) => RewardPage(reward: widget._reward)));
    if (result != null) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _reward = widget._reward;

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      child: Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: Padding(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: SizedBox.fromSize(
                size: Size(56, 56), // button width and height
                child: ClipOval(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      MyStyle.COST_ICON,
                      Text(_reward.cost.toString(), style: TextStyle(color: theme.errorColor), textScaleFactor: 1.2), // text
                    ],
                  ),
                ),
              ),
            ),
            title: Text(_reward.name),
            trailing: MyStyle.GOAL_ICON,
            subtitle: _boughtReward == null ? null : Text('Last purchase on ' + MyFormatter.dateTimeFormat.format(_boughtReward.boughtAt)),
          ),
          ButtonBar(
            children: <Widget>[
              ValueListenableBuilder(
                valueListenable: widget._credit,
                builder: (context, credit, child) {
                  // TODO this is called twice by Flutter but why?
                  // _log.debug('Building reward action button for reward ${_reward.id} with value $credit ...');
                  return RaisedButton(
                      child: const Text('REWARD MYSELF'),
                      onPressed: (_reward.cost <= credit ? () => _buyReward() : null));
                },
              ),
            ],
          )
        ]),
      ),
      secondaryActions: <Widget>[
        Padding(
          padding: ACTION_PADDING,
          child: IconSlideAction(
              caption: 'DELETE',
              color: theme.errorColor,
              icon: Icons.delete,
              onTap: () => widget.deleteRewardCallback(_reward, context)),
        ),
        Padding(
          padding: ACTION_PADDING,
          child: IconSlideAction(
            caption: 'EDIT',
            color: theme.primaryColor,
            icon: Icons.edit,
            onTap: () => _editReward(),
          ),
        ),
      ],
    );
  }
}
