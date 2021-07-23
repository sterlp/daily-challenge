import 'package:challengeapp/challengelist/i18n/challengelist_localization.dart';
import 'package:challengeapp/common/common_types.dart';
import 'package:challengeapp/common/model/attached_entity.dart';
import 'package:challengeapp/common/widget/delete_list_action.dart';
import 'package:challengeapp/home/state/app_state_widget.dart';
import 'package:challengeapp/i18n/challenge_localization_delegate.dart';
import 'package:challengeapp/reward/model/bought_reward_model.dart';
import 'package:challengeapp/reward/model/reward_model.dart';
import 'package:challengeapp/reward/page/reward_page.dart';
import 'package:challengeapp/reward/service/reward_service.dart';
import 'package:challengeapp/reward/widget/buy_reward_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class RewardCardWidget extends StatefulWidget {
  final Reward _reward;
  final ValueNotifier<int> _credit;
  final ValueChanged<Reward> deleteCallback;
  final ValueChanged<Reward> undoDeleteCallback;

  RewardCardWidget(this._reward, this._credit, this.deleteCallback, this.undoDeleteCallback,
      {Key key}) : super(key: key);

  @override
  _RewardCardWidgetState createState() => _RewardCardWidgetState();
}

class _RewardCardWidgetState extends State<RewardCardWidget> with SingleTickerProviderStateMixin {
  static const ACTION_PADDING = EdgeInsets.all(4.0);

  AnimationController _animationController;
  RewardService _rewardService;
  BoughtReward _boughtReward;
  ChallengeLocalizations _commonI18n;
  ChallengeListLocalizations _i18n;
  AttachedEntity<Reward> _attached;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _animationController.reverse();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _rewardService = AppStateWidget.of(context).get<RewardService>();
    _commonI18n = Localizations.of<ChallengeLocalizations>(context, ChallengeLocalizations);
    _i18n = Localizations.of<ChallengeListLocalizations>(context, ChallengeListLocalizations);
    _loadBoughtReward();
    if (_attached != null) {
      _attached.close();
      _attached = null;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_attached != null) _attached.close();
    super.dispose();
  }

  void _loadBoughtReward() async {
    var boughtReward = await _rewardService.getLastBoughtRewardByRewardId(widget._reward.id);
    if (boughtReward != null && boughtReward != _boughtReward) {
      setState(() => _boughtReward = boughtReward);
    }
  }

  void _buyReward() async {
    final buy = await showBuyRewardDialog(context, widget._reward, widget._credit.value);
    if (buy) {
      _boughtReward = await _rewardService.buyReward(widget._reward);
      _animationController.forward();
      setState(() {});
    }
  }

  void _editReward() async {
    var result = await Navigator.push(
      context, MaterialPageRoute<Reward>(
      builder: (BuildContext context) => RewardPage(reward: widget._reward), fullscreenDialog: true)
    );
    if (result != null) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _reward = widget._reward;
    _attached ??= _rewardService.attach(_reward);

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      child: Card(
        child: ListTile(
          onLongPress: _editReward,
          leading: Padding(
            padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedBuilder(
                  child: MyStyle.COST_ICON,
                  animation: _animationController,
                  builder: (BuildContext context, Widget _widget) {
                    return Transform.scale(
                      scale: 1 + _animationController.value,
                      child: _widget,
                    );
                  }
                ),
                Text('${_reward.cost}', style: TextStyle(color: theme.errorColor), textScaleFactor: 1.2), // text
              ],
            ),
          ),
          title: Text(_reward.name),
          subtitle: _boughtReward == null
              ? null
              : Text(_i18n.lastPurchase(_commonI18n.formatDateTime(_boughtReward.boughtAt))),
          isThreeLine: _boughtReward != null,
          trailing: ValueListenableBuilder<int>(
            valueListenable: widget._credit,
            builder: (context, credit, child) {
              // TODO this is called twice by Flutter but why?
              // _log.debug('Building reward action button for reward ${_reward.id} with value $credit ...');
              return SizedBox(
                width: 64,
                child: RaisedButton(
                  child: MyStyle.GOAL_ICON,
                  onPressed: (_reward.cost <= credit ? () => _buyReward() : null)),
              );
            },
          ),
        ),
      ),
      secondaryActions: <Widget>[
        Padding(
          padding: ACTION_PADDING,
          child: DeleteListAction(
            _attached, "Reward deleted.",
            deleteCallback: widget.deleteCallback, undoDeleteCallback: widget.undoDeleteCallback,
          ),
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
