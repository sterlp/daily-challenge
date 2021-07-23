import 'package:challengeapp/challengelist/i18n/challengelist_localization.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/challengelist/page/challenge_page.dart';
import 'package:challengeapp/challengelist/service/challenge_service.dart';
import 'package:challengeapp/challengelist/widget/challenge_widget.dart';
import 'package:challengeapp/common/common_types.dart';
import 'package:challengeapp/common/widget/scroll_view_position_listener.dart';
import 'package:challengeapp/credit/service/credit_service.dart';
import 'package:challengeapp/home/state/app_state_widget.dart';
import 'package:challengeapp/home/widget/loading_widget.dart';
import 'package:challengeapp/home/widget/total_points_widget.dart';
import 'package:challengeapp/i18n/challenge_localization_delegate.dart';
import 'package:challengeapp/log/logger.dart';
import 'package:challengeapp/util/date.dart';
import 'package:flutter/material.dart';

class ChallengeListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChallengeListPageState();
}

class ChallengeListPageState extends State<ChallengeListPage> with ScrollViewPositionListener<ChallengeListPage> {
  static final Logger _log = LoggerFactory.get<ChallengeListPageState>();

  CreditService _creditService;
  ChallengeService _challengeService;
  ValueNotifier<int> _credit;
  DateTime _selectedDay = DateTime.now();

  final ValueNotifier<List<Challenge>> _data = ValueNotifier(null);

  ChallengeListLocalizations i18n;
  ChallengeLocalizations commonI18n;

  @override
  void didChangeDependencies() {
    i18n = Localizations.of<ChallengeListLocalizations>(context, ChallengeListLocalizations);
    commonI18n = Localizations.of<ChallengeLocalizations>(context, ChallengeLocalizations);
    _challengeService = AppStateWidget.of(context).get<ChallengeService>();
    _creditService = AppStateWidget.of(context).get<CreditService>();
    _credit = _creditService.creditNotifier;
    super.didChangeDependencies();
  }

  Future<void> _doReload() async {
    var result = <Challenge>[];
    try {
      final isToday = DateTimeUtil.clearTime(_selectedDay).millisecondsSinceEpoch
          == DateTimeUtil.clearTime(DateTime.now()).millisecondsSinceEpoch;

      _log.startSync('ChallengeListPage._doReload, ${isToday ? "today" : "not today"}.');

      result = await _challengeService.loadByDate(_selectedDay, isToday);

      await _creditService.credit;

    } catch (e) {
      _log.error('_doReload failed!', e);
      rethrow;
    } finally {
      _log.finishSync();
    }
    _data.value = result;
  }

  Future<void> _createChallenge() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute<dynamic>(builder: (BuildContext context) =>
            ChallengePage(challenge: Challenge()..dueAt = _selectedDay), fullscreenDialog: true)
    );
    if (result != null) return _doReload();
    return;
  }

  Widget _buildChallenges(List<Challenge> _challenges) {
    if (_challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('No challenges today!', style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: 8),
            Text('${commonI18n.formatDate(_selectedDay)}', style: Theme.of(context).textTheme.headline6)
          ]
        )
      );
    } else {
      return ListView.builder(
        padding: MyStyle.LIST_PADDING,
        controller: scrollController,
        itemCount: _challenges.length,
        itemBuilder: (context, index) {
          final e = _challenges[index];
          return ChallengeWidget(e,
            deleteCallback: _onDeleteChallenge,
            undoDeleteCallback: (e) => _doReload(),
            key: ObjectKey(e),
          );
        }
      );
    }
  }

  void _onDeleteChallenge(Challenge c) {
    final newData = List<Challenge>.from(_data.value);
    if (newData.remove(c)) {
      _data.value = newData;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_data.value == null) _doReload();

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        // shape: CircularNotchedRectangle(),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: <Widget>[
            FlatButton.icon(
              key: const ValueKey('home_day_select'),
              onPressed: () async {
                var newDate = await showDatePicker(context: context, initialDate: _selectedDay,
                    firstDate: _selectedDay.add(const Duration(days: -60)),
                    lastDate: _selectedDay.add(const Duration(days: 60)));
                if (newDate != null && newDate.millisecondsSinceEpoch != _selectedDay.millisecondsSinceEpoch) {
                  _log.debug('date $newDate selected.');
                  _selectedDay = newDate;
                  _doReload();
                }
              },
              icon: const Icon(Icons.arrow_drop_down),
              label: Text(commonI18n.formatDate(_selectedDay),
                  style: const TextStyle(fontWeight: FontWeight.w600))
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TotalPointsWidget(_credit),
            )
          ],
        ),
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: scrolledToBottom,
        builder: (context, value, child) => AnimatedOpacity(
          opacity: value ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 600),
          child: ValueListenableBuilder<bool>(
            valueListenable: showFab,
              child: FloatingActionButton.extended(
                onPressed: _createChallenge,
                icon: const Icon(Icons.add),
                label: Text(i18n.newChallengeButton),
              ),
            builder: (context, value, child) => Visibility(
              visible: value,
              child: child
            ),
          ),
          onEnd: () {
            if (value && showFab.value) showFab.value = false;
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ValueListenableBuilder<List<Challenge>>(
        valueListenable: _data,
        builder: (context, value, child) {
          _log.debug('build has data ${value != null}...');
          if (value != null) return _buildChallenges(value);
          else return LoadingWidget();
        },
      )
    );
  }
}
