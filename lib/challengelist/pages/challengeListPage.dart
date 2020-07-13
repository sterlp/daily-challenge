import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutterapp/challengelist/models/challengeModel.dart';
import 'package:flutterapp/challengelist/services/challengeService.dart';
import 'package:flutterapp/challengelist/views/challengeWidget.dart';
import 'package:flutterapp/db/testData.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
import 'package:flutterapp/log/logger.dart';
import 'package:flutterapp/util/date.dart';
import 'package:intl/intl.dart';

class ChallengeListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChallengeListPageState();
}

class ChallengeListPageState extends State<ChallengeListPage> {
  static final DateFormat doneFormat = DateFormat("LLLL dd.MM");
  static final Logger _log = LoggerFactory.get<ChallengeListPageState>();

  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey();
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

  _reload() async {
    final isToday = DateTimeUtil.clearTime(_selectedDay).millisecondsSinceEpoch == DateTimeUtil.clearTime(DateTime.now()).millisecondsSinceEpoch;
    _log.debug('_reload, ${isToday ? "today" : "not today"}  ');
    _challengeService.getTotal();
    var current = await _challengeService.loadByDate(_selectedDay);
    var overDue = <Challenge>[];
    // if ( (await _challengeService.load()).length == 0 ) await this._container.get<TestData>().generateTestData();


    if (isToday) {
      overDue = await _challengeService.loadOverDue();
      // TODO just for now, business logic in view
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
    if (wasEmpty && _challenges.isEmpty) {
      // nothing needs to be done, empty to empty
    } else {
      setState(() {});
    }
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
      return ListView(children: tiles.toList());
    }
  }

  _onDeleteChallenge(Challenge c, BuildContext context) async {
    await _challengeService.delete(c);
    setState(() {
      _challenges.remove(c);
    });
    _scaffold.currentState.showSnackBar(SnackBar(content: Text("${c.name} deleted.")));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _log.debug('build...');
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text('Kick your butt today'),
        actions: <Widget>[
          FlatButton.icon(onPressed: () async {
            var newDate = await showDatePicker(context: context, initialDate: _selectedDay,
                firstDate: _selectedDay.add(Duration(days: -60)), lastDate: _selectedDay.add(Duration(days: 60)));
            if (newDate != null && newDate.millisecondsSinceEpoch != _selectedDay.millisecondsSinceEpoch) {
              _log.debug('date $newDate selected.');
              _selectedDay = newDate;
              _reload();
            }
          },
          icon: Icon(Icons.arrow_drop_down), label: Text(doneFormat.format(_selectedDay))),
          FlatButton.icon(
              onPressed: () async {
                _challengeService.deleteAll();
                await AppStateWidget.of(context).get<TestData>().generateData(10, daysPast: 5, daysFuture: 50);
                _reload();
              },
              icon: Icon(Icons.add), label: Text("Generate Test Data")
          )
        ]
      ),

      body: _buildChallenges(),
    );
  }
}
