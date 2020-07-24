import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterapp/common/common_types.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
import 'package:flutterapp/reward/model/bought_reward_model.dart';
import 'package:flutterapp/reward/model/reward_model.dart';
import 'package:flutterapp/reward/page/reward_page.dart';
import 'package:flutterapp/reward/service/reward_service.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

typedef RewardCallback = void Function(Reward reward, BuildContext context);

class RewardCardWidget extends StatefulWidget {
  final Reward _reward;
  final int credit;
  final RewardCallback buyRewardCallback;
  final RewardCallback deleteRewardCallback;

  RewardCardWidget(this._reward, this.credit, this.buyRewardCallback, this.deleteRewardCallback, {Key key}) : super(key: key);

  @override
  _RewardCardWidgetState createState() => _RewardCardWidgetState(_reward);
}

class _RewardCardWidgetState extends State<RewardCardWidget> {

  static const ACTION_PADDING = EdgeInsets.all(4.0);
  Reward _reward;
  Future<BoughtReward> _boughtReward;

  _RewardCardWidgetState(this._reward);

  @override
  Widget build(BuildContext context) {
    _boughtReward ??= AppStateWidget.of(context).get<RewardService>().getLastBoughtRewardByRewardId(_reward.id);
    final theme = Theme.of(context);
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      child: Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          FutureBuilder<BoughtReward>(
            future: _boughtReward,
            builder: (context, snapshot) => ListTile(
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
              subtitle: snapshot.data == null ? null : Text('Last purchase on ' + MyFormatter.dateTimeFormat.format(snapshot.data.boughtAt)),
            ),
          ),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                  child: const Text('REWARD MYSELF'),
                  onPressed: (_reward.cost <= widget.credit ? () => widget.buyRewardCallback(_reward, context) : null)),
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
            onTap: () async {
              var result = await Navigator.push(
                  context, MaterialPageRoute<Reward>(builder: (BuildContext context) => RewardPage(reward: _reward)));
              if (result != null) setState(() => _reward = result);
            },
          ),
        ),
      ],
    );
  }
}
