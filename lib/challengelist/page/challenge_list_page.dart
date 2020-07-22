import 'package:flutter/material.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/challengelist/page/challenge_page.dart';
import 'package:flutterapp/challengelist/service/challenge_service.dart';
import 'package:flutterapp/challengelist/widget/challenge_widget.dart';
import 'package:flutterapp/credit/service/credit_service.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
import 'package:flutterapp/home/widget/loading_widget.dart';
import 'package:flutterapp/home/widget/total_points_widget.dart';
import 'package:flutterapp/log/logger.dart';
import 'package:flutterapp/util/date.dart';
import 'package:intl/intl.dart';

class ChallengeListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChallengeListPageState();
}

class ChallengeListPageState extends State<ChallengeListPage> {
  static final DateFormat doneFormat = DateFormat("EEEE, dd.MM");
  static final Logger _log = LoggerFactory.get<ChallengeListPageState>();

  CreditService _creditService;
  ChallengeService _challengeService;
  ValueNotifier<int> _credit;
  DateTime _selectedDay = DateTime.now();

  Future<List<Challenge>> _data;

  // InheritedWidget doesn't work with initState, Flutter isn't consistent here.
  @override
  void initState() {
    super.initState();
  }

  Future<List<Challenge>> _doReload() async {
    if (_challengeService == null) _challengeService = AppStateWidget.of(context).get<ChallengeService>();
    if (_creditService == null) _creditService = AppStateWidget.of(context).get<CreditService>();
    if (_credit == null) _credit = _creditService.creditNotifier;

    final isToday = DateTimeUtil.clearTime(_selectedDay).millisecondsSinceEpoch == DateTimeUtil.clearTime(DateTime.now()).millisecondsSinceEpoch;
    List<Challenge> _challenges = [];
    _log.startSync('ChallengeListPage._doReload, ${isToday ? "today" : "not today"}.');

    await _creditService.credit;

    final current = await _challengeService.loadByDate(_selectedDay);
    var overDue = <Challenge>[];

    // TODO just for now, business logic in view
    if (isToday) {
      overDue = await _challengeService.loadOverDue();
      await _challengeService.failOverDue(overDue);
    }

    _challenges.clear();
    _challenges.addAll(overDue);
    if (_challenges.length > 0) {
      for (Challenge c in current) {
        if (!_challenges.contains(c)) _challenges.add(c);
      }
    } else {
      _challenges.addAll(current);
    }

    _log.finishSync();
    return _challenges;
  }

  Widget _buildChallenges(List<Challenge> _challenges) {
    if (_challenges.length == 0) {
      return Center(child: Text('No challenges today, ${doneFormat.format(_selectedDay)}.', textScaleFactor: 1.5));
    } else {

      final Iterable<Widget> tiles = _challenges.map((e) => ChallengeWidget(
          challenge: e,
          onDelete: _onDeleteChallenge,
          key: ValueKey(e),
        )
      );
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(children: tiles.toList())
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
    _log.debug('build...');
    if (_data == null) _data = _doReload();

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: <Widget>[
            FlatButton.icon(onPressed: () async {
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
                label: Text(doneFormat.format(_selectedDay), style: TextStyle(fontWeight: FontWeight.w600))
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TotalPointsWidget(_credit),
            )
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
              context,
              MaterialPageRoute<Challenge>(builder: (BuildContext context) => ChallengePage(challenge: Challenge()))
          );
          if (result != null) {
            _data = _doReload();
            setState(() {});
          }
        },
        child: Icon(Icons.add)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: FutureBuilder(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.hasData) return _buildChallenges(snapshot.data);
          else return LoadingWidget();
        },
      )
    );
  }
}
