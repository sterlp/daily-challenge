import 'package:flutter/material.dart';
import 'package:challengeapp/common/widget/fixed_flutter_state.dart';
import 'package:challengeapp/common/widget/scroll_view_position_listener.dart';
import 'package:challengeapp/container/app_context.dart';
import 'package:challengeapp/credit/service/credit_service.dart';
import 'package:challengeapp/home/state/app_state_widget.dart';
import 'package:challengeapp/home/widget/loading_widget.dart';
import 'package:challengeapp/home/widget/total_points_widget.dart';
import 'package:challengeapp/log/logger.dart';
import 'package:challengeapp/reward/model/reward_model.dart';
import 'package:challengeapp/reward/page/reward_page.dart';
import 'package:challengeapp/reward/service/reward_service.dart';
import 'package:challengeapp/reward/widget/reward_card_widget.dart';
import 'package:challengeapp/common/common_types.dart';

class RewardShopPage extends StatefulWidget {
  final AppContext appContext;
  
  RewardShopPage({Key key, this.appContext}) : super(key: key);

  @override
  _RewardShopPageState createState() => _RewardShopPageState();
}

class _RewardShopPageState extends FixedState<RewardShopPage> with ScrollViewPositionListener<RewardShopPage> {
  static final Logger _log = LoggerFactory.get<RewardShopPage>();

  AppContext _appContext;
  RewardService _rewardService;
  CreditService _creditService;
  List<Reward> _rewards;
  ValueNotifier<int> _totalCredit;

  void _reload() async {
    if (mounted) {
      try {
        _log.startSync('Reload ...');
        await _creditService.credit;
        _rewards = await _rewardService.listRewards(999, 0);
        if (mounted) setState(() {});
      } catch(e) {
        _log.error('Reload failed.', e);
      } finally {
        _log.finishSync();
      }
    }
  }

  void _deleteReward(Reward r) {
    _log.debug('delete reward $r');
    setState(() => _rewards.remove(r));
  }
  void _undoDeleteReward(Reward r) {
    _log.debug('undo delete reward $r');
    _reload();
  }

  void _createReward() async {
    var result = await Navigator.push(context, MaterialPageRoute<Reward>(builder: (BuildContext context) =>
        RewardPage(reward: Reward()), fullscreenDialog: true));
    _log.debug('RewardPage returned with $result');
    if (result != null) _reload();
  }

  Widget _buildBody(BuildContext context) {
    _log.debug('_buildBody has data ${_rewards != null} ...');
    Widget result;
    if (_rewards == null) {
      result = LoadingWidget();
    } else if (_rewards.isEmpty) {
      result = _buildEmptyStore(context);
    } else {
      result = _buildResult(context, _rewards);
    }
    return result;
  }

  @override
  void saveInitState() {
    _reload();
    super.saveInitState();
  }

  @override
  void didChangeDependencies() {
    _appContext = widget.appContext == null ? AppStateWidget.of(context) : widget.appContext;
    _rewardService = _appContext.get<RewardService>();
    _creditService = _appContext.get<CreditService>();
    _totalCredit = _creditService.creditNotifier;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: _buildBody(context),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: scrolledToBottom,
        builder: (context, value, child) => AnimatedOpacity(
          opacity: value ? 0.0 : 1.0,
          duration: Duration(milliseconds: 500),
          child: ValueListenableBuilder(
            valueListenable: showFab,
            builder: (context, value, child) => Visibility(
              visible: value,
              child: FloatingActionButton.extended(
                onPressed: _createReward,
                tooltip: 'New Reward',
                icon: Icon(Icons.add),
                label: Text('Create Reward'),
              ),
            ),
          ),
          onEnd: () {
            if (value && showFab.value) showFab.value = false;
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomAppBar(
        // shape: CircularNotchedRectangle(),
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
    return ListView.builder(
      padding: MyStyle.LIST_PADDING,
      itemCount: rewards.length,
      controller: scrollController,
      itemBuilder: (BuildContext context, int index) {
        final reward = rewards[index];
        return RewardCardWidget(reward, _totalCredit,
            _deleteReward, _undoDeleteReward,
            key: ObjectKey(reward)
        );
      }
    );
  }

  Widget _buildEmptyStore(BuildContext context) {
    return Center(child: Text('No rewards created yet', style: Theme.of(context).textTheme.headline5));
  }
}
