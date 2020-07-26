import 'package:flutter/material.dart';
import 'package:flutterapp/common/widget/scroll_view_position_listener.dart';
import 'package:flutterapp/container/app_context.dart';
import 'package:flutterapp/credit/service/credit_service.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
import 'package:flutterapp/home/widget/loading_widget.dart';
import 'package:flutterapp/home/widget/total_points_widget.dart';
import 'package:flutterapp/log/logger.dart';
import 'package:flutterapp/reward/model/reward_model.dart';
import 'package:flutterapp/reward/page/reward_page.dart';
import 'package:flutterapp/reward/service/reward_service.dart';
import 'package:flutterapp/reward/widget/reward_card_widget.dart';

class RewardShopPage extends StatefulWidget {
  final AppContext appContext;
  
  RewardShopPage({Key key, this.appContext}) : super(key: key);

  @override
  _RewardShopPageState createState() => _RewardShopPageState();
}

class _RewardShopPageState extends State<RewardShopPage> with ScrollViewPositionListener<RewardShopPage> {
  static final Logger _log = LoggerFactory.get<RewardShopPage>();

  AppContext _appContext;
  RewardService _rewardService;
  CreditService _creditService;
  List<Reward> _rewards;
  ValueNotifier<int> _totalCredit;

  @override
  void initState() {
    super.initState();
    initScrollListener();
  }

  @override
  void dispose() {
    super.dispose();
    disposeScrollListener();
  }

  void _reload() async {
    try {
      _log.startSync('Reload ...');
      await _creditService.credit;
      _rewards = await _rewardService.listRewards(999, 0);
      setState(() {});
    } catch(e) {
      _log.error('Reload failed.', e);
    } finally {
      _log.finishSync();
    }
  }

  void _deleteReward(Reward r, BuildContext context) async {
    _log.debug('delete reward $r');
    await _rewardService.deleteReward(r);
    _rewards.remove(r);
    setState(() {});
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appContext ??= widget.appContext == null ? AppStateWidget.of(context) : widget.appContext;
    _rewardService ??= _appContext.get<RewardService>();
    _creditService ??= _appContext.get<CreditService>();
    _totalCredit ??= _creditService.creditNotifier;
    if (_rewards == null) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
      floatingActionButton: AnimatedOpacity(
        opacity: scrolledToBottom ? 0.0 : 1.0,
        duration: Duration(milliseconds: 500),
        child: Visibility(
          visible: showFab,
          child: FloatingActionButton.extended(
            onPressed: _createReward,
            tooltip: 'New Reward',
            icon: Icon(Icons.add),
            label: Text('Create Reward'),
          ),
        ),
        onEnd: () {
          if (scrolledToBottom && showFab) setState(() { showFab = false; });
        },
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
      itemCount: rewards.length,
      padding: const EdgeInsets.all(8.0),
      controller: scrollController,
      itemBuilder: (BuildContext context, int index) {
        final reward = rewards[index];
        return RewardCardWidget(reward, _totalCredit, _deleteReward, key: ObjectKey(reward));
      }
    );
  }

  Widget _buildEmptyStore(BuildContext context) {
    return Center(child: Text('No rewards created yet', style: Theme.of(context).textTheme.headline5));
  }
}
