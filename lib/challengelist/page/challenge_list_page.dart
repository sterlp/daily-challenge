import 'package:flutter/material.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/challengelist/page/challenge_page.dart';
import 'package:flutterapp/challengelist/service/challenge_service.dart';
import 'package:flutterapp/challengelist/widget/challenge_widget.dart';
import 'package:flutterapp/common/common_types.dart';
import 'package:flutterapp/credit/service/credit_service.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
import 'package:flutterapp/home/widget/loading_widget.dart';
import 'package:flutterapp/home/widget/total_points_widget.dart';
import 'package:flutterapp/log/logger.dart';
import 'package:flutterapp/util/date.dart';

class ChallengeListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChallengeListPageState();
}

class ChallengeListPageState extends State<ChallengeListPage> {
  static final Logger _log = LoggerFactory.get<ChallengeListPageState>();

  CreditService _creditService;
  ChallengeService _challengeService;
  ValueNotifier<int> _credit;
  DateTime _selectedDay = DateTime.now();

  Future<List<Challenge>> _data;

  Future<List<Challenge>> _doReload() async {
    List<Challenge> result = [];
    try {
      _challengeService ??= AppStateWidget.of(context).get<ChallengeService>();
      _creditService ??= AppStateWidget.of(context).get<CreditService>();
      _credit ??= _creditService.creditNotifier;

      final isToday = DateTimeUtil.clearTime(_selectedDay).millisecondsSinceEpoch == DateTimeUtil.clearTime(DateTime.now()).millisecondsSinceEpoch;

      _log.startSync('ChallengeListPage._doReload, ${isToday ? "today" : "not today"}.');

      await _creditService.credit;

      final current = await _challengeService.loadByDate(_selectedDay);
      var overDue = <Challenge>[];

      // TODO just for now, business logic in view
      if (isToday) {
        overDue = await _challengeService.loadOverDue();
        await _challengeService.failOverDue(overDue);
      }

      result.clear();
      result.addAll(overDue);
      if (result.length > 0) {
        for (Challenge c in current) {
          if (!result.contains(c)) result.add(c);
        }
      } else {
        result.addAll(current);
      }
    } catch (e) {
      _log.error('_doReload failed!', e);
    } finally {
      _log.finishSync();
    }
    return result;
  }

  void _createChallenge() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute<dynamic>(builder: (BuildContext context) => ChallengePage(challenge: Challenge()), fullscreenDialog: true)
    );
    if (result != null) {
      _data = _doReload();
      setState(() {});
    }
  }

  Widget _buildChallenges(List<Challenge> _challenges) {
    if (_challenges.length == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('No challenges today!', style: Theme.of(context).textTheme.headline5),
            SizedBox(height: 8),
            Text('${MyFormatter.dateFormat.format(_selectedDay)}', style: Theme.of(context).textTheme.headline6)
          ]
        )
      );
    } else {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: _challenges.length,
            itemBuilder: (context, index) {
              final e = _challenges[index];
              return ChallengeWidget(
                challenge: e,
                onDelete: _onDeleteChallenge,
                key: ObjectKey(e),
              );
            }
          )
      );
    }
  }

  _onDeleteChallenge(Challenge c, BuildContext context) async {
    await _challengeService.delete(c);
    _data = _doReload();
    setState(() { });
    Scaffold.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("'${c.name}' was deleted."),
        action: SnackBarAction(label: 'Undo', onPressed: () async {
          _log.info('Undo delete of $c');
          await _challengeService.insert(c);
          _data = _doReload();
          setState(() {});
        }),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) _data = _doReload();

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        // shape: CircularNotchedRectangle(),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: <Widget>[
            FlatButton.icon(
              onPressed: () async {
                var newDate = await showDatePicker(context: context, initialDate: _selectedDay,
                    firstDate: _selectedDay.add(Duration(days: -60)), lastDate: _selectedDay.add(Duration(days: 60)));
                if (newDate != null && newDate.millisecondsSinceEpoch != _selectedDay.millisecondsSinceEpoch) {
                  _log.debug('date $newDate selected.');
                  _selectedDay = newDate;
                  _data = _doReload();
                  setState(() {});
                }
              },
              icon: Icon(Icons.arrow_drop_down),
              label: Text(MyFormatter.dateFormat.format(_selectedDay), style: TextStyle(fontWeight: FontWeight.w600))
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TotalPointsWidget(_credit),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createChallenge,
        icon: Icon(Icons.add),
        label: Text('New Challenge'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: FutureBuilder(
        future: _data,
        builder: (context, snapshot) {
          _log.debug('build has data ${snapshot.hasData}...');
          if (snapshot.hasData) return _buildChallenges(snapshot.data);
          else return LoadingWidget();
        },
      )
    );
  }
}
