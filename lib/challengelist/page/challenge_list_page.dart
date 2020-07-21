import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/challengelist/page/challenge_page.dart';
import 'package:flutterapp/challengelist/service/challenge_service.dart';
import 'package:flutterapp/challengelist/widget/challenge_widget.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
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

  ChallengeService _challengeService;
  DateTime _selectedDay = DateTime.now();
  final List<Challenge> _challenges = [];

  // InheritedWidget doesn't work with initState, Flutter isn't consistent here.
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _challengeService = AppStateWidget.of(context).get<ChallengeService>();
      _reload();
    });
  }

  _reload([bool force = false]) async {
    final isToday = DateTimeUtil.clearTime(_selectedDay).millisecondsSinceEpoch == DateTimeUtil.clearTime(DateTime.now()).millisecondsSinceEpoch;
    _log.startSync('ChallengeListPage._reload, ${isToday ? "today" : "not today"}.');
    if (force) _challengeService.calcTotal();
    else _challengeService.getTotal();

    var current = await _challengeService.loadByDate(_selectedDay);
    var overDue = <Challenge>[];

    // TODO just for now, business logic in view
    if (isToday) {
      overDue = await _challengeService.loadOverDue();
      await _challengeService.failOverDue(overDue);
    }

    final wasEmpty = _challenges.isEmpty;
    _challenges.clear();
    _challenges.addAll(overDue);
    if (_challenges.length > 0) {
      for (Challenge c in current) {
        if (!_challenges.contains(c)) _challenges.add(c);
      }
    } else {
      _challenges.addAll(current);
    }
    if (!force && (wasEmpty && _challenges.isEmpty)) {
      // nothing needs to be done, empty to empty
    } else {
      setState(() {});
    }
    _log.finishSync();
  }

  Widget _buildChallenges() {
    if (_challenges.length == 0) {
      return Center(child: Text('No challenges today, ${doneFormat.format(_selectedDay)}.', textScaleFactor: 1.5));
    } else {

      final Iterable<Widget> tiles = _challenges.map((e) => ChallengeWidget(
          challenge: e,
          onDelete: _onDeleteChallenge
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
    setState(() {
      _challenges.remove(c);
    });
    Scaffold.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("'${c.name}' was deleted."),
        action: SnackBarAction(label: 'Undo', onPressed: () async {
          _log.info('Undo delete of $c');
          await _challengeService.insert(c);
          _reload();
        }),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    _log.debug('build...');
    if (_challengeService == null) _challengeService = AppStateWidget.of(context).get<ChallengeService>();
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
                _reload();
              }
            },
                icon: Icon(Icons.arrow_drop_down),
                label: Text(doneFormat.format(_selectedDay), style: TextStyle(fontWeight: FontWeight.w600))
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TotalPointsWidget(_challengeService.totalPoints),
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
          if (result != null) _reload();
        },
        child: Icon(Icons.add)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: _buildChallenges(),
    );
  }
}
