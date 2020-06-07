import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterapp/challengelist/dao/challengeDao.dart';
import 'package:flutterapp/challengelist/models/challengeModel.dart';
import 'package:flutterapp/challengelist/pages/challengePage.dart';
import 'package:flutterapp/challengelist/services/challengeService.dart';
import 'package:flutterapp/challengelist/views/challengeWidget.dart';
import 'package:flutterapp/db/dbProvider.dart';
import 'package:flutterapp/db/testData.dart';
import 'package:flutterapp/util/container.dart';
import 'package:flutterapp/util/date.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as dev;

class ChallengeListPage extends StatefulWidget {
  final DiContainer _container;

  const ChallengeListPage(this._container, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChallengeListPageState(_container);
}

class ChallengeListPageState extends State<ChallengeListPage> {
  static final DateFormat doneFormat = DateFormat("LLLL dd.MM");

  final GlobalKey<ScaffoldState> _scaffold = new GlobalKey();
  DateTime _selectedDay = DateTime.now();
  final DiContainer _container;
  final ChallengeService _challengeService;
  final List<Challenge> _challenges = [];

  ChallengeListPageState._(this._container, this._challengeService) {
    _reload();
    _challengeService.challengeChangedStream.listen((changed) => _reload(changed: changed));
  }

  factory ChallengeListPageState(DiContainer container) {
    return new ChallengeListPageState._(container, container.get<ChallengeService>());
  }

  _reload({List<Challenge> changed}) async {
    // if ( (await _challengeService.load()).length == 0 ) await this._container.get<TestData>().generateTestData();
    var current = await _challengeService.loadByDate(_selectedDay);
    var overDue = <Challenge>[];
    var isToday = DateTimeUtil.clearTime(_selectedDay).millisecondsSinceEpoch == DateTimeUtil.clearTime(DateTime.now()).millisecondsSinceEpoch;

    if (isToday) {
      overDue = await _challengeService.loadOverDue();
      // TODO just for now, business logic in view
      await _challengeService.failOverDue(overDue);
    }

    _challenges.clear();
    _challenges.addAll(overDue);

    setState(() {
      if (_challenges.length > 0) {
        for (Challenge c in current) {
          if (!_challenges.contains(c)) _challenges.add(c);
        }
      } else {
        _challenges.addAll(current);
      }
    });
  }

  _onChallengeChecked(Challenge challenge, bool value) async {
    if (challenge.isFailed) {
      _scaffold.currentState
          .showSnackBar(SnackBar(content: Text('Challenge ${challenge.name} already failed.')));
    } else {
      if (value) {
        await _challengeService.complete([challenge]);
      } else {
        await _challengeService.incomplete([challenge]);
      }
      // update view
      setState(() { });
    }
  }

  Widget _buildChallenges() {
    if (_challenges.length == 0) {
      return Center(child: Text('No challenges today, ${doneFormat.format(_selectedDay)}.', textScaleFactor: 1.5));
    }
    const edge = EdgeInsets.all(4.0);
    final Iterable<Widget> tiles = _challenges.map((e) => Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Card(child: ChallengeWidget(challenge: e, onChecked: _onChallengeChecked)),
        secondaryActions: <Widget>[
          Padding(
            padding: edge,
            child: IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () => _doDeleteChallenge(e)
            ),
          ),
          Padding(
            padding: edge,
            child: IconSlideAction(
              caption: 'Edit',
              color: Colors.indigo,
              icon: Icons.edit,
              onTap: () => _doEditChallenge(context, e)
            ),
          ),
        ]
      )
    );
    return ListView(children: tiles.toList());
  }

  _doDeleteChallenge(Challenge c) async {
    await _challengeService.delete(c);
    _scaffold.currentState.showSnackBar(SnackBar(content: Text("${c.name} deleted.")));
  }

  _doEditChallenge(BuildContext context, Challenge c) async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute<Challenge>(
            builder: (BuildContext context) => ChallengePage(challenge: c, challengeService: _challengeService)
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text('Kick your butt today'),
        actions: <Widget>[
          FlatButton.icon(onPressed: () async {
            var newDate = await showDatePicker(context: context, initialDate: _selectedDay,
                firstDate: _selectedDay.add(Duration(days: -60)), lastDate: _selectedDay.add(Duration(days: 60)));
            if (newDate != null && newDate.millisecondsSinceEpoch != _selectedDay.millisecondsSinceEpoch) {
              _selectedDay = newDate;
              _reload();
            }
          },
          icon: Icon(Icons.arrow_drop_down), label: Text(doneFormat.format(_selectedDay)))
        ],
      ),

      body: _buildChallenges(),
    );
  }
}
