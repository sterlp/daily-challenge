import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/challengelist/service/challenge_service.dart';
import 'package:flutterapp/common/common_types.dart';
import 'package:flutterapp/common/widget/input_form.dart';
import 'package:flutterapp/db/test_data.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
import 'package:flutterapp/util/date.dart';
import 'package:flutterapp/util/strings.dart';

class ChallengePage extends StatefulWidget {
  final Challenge challenge;

  ChallengePage({Key key, @required this.challenge}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChallengePageState();
}
class ChallengePageState extends State<ChallengePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController();

  final TextEditingController _dueAtController = TextEditingController();
  DateTime _dueAt;
  final TextEditingController _latestUntilController = TextEditingController();

  DateTime _latestAt;
  ChallengeService _challengeService;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _challengeService ??= AppStateWidget.of(context).get<ChallengeService>();
    });
    final c = widget.challenge;
    _nameController.text = c.name;
    _rewardController.text = c.reward == null ? null : c.reward.toString();

    _dueAt = c.dueAt;
    _dueAtController.text = DateTimeUtil.formatDate(_dueAt);
    _latestAt = c.latestAt;
    _latestUntilController.text = DateTimeUtil.formatDate(_latestAt);
  }

  _save() async {
    if (_formKey.currentState.validate()) {
      var c = widget.challenge;
      c.name = _nameController.text;
      if (_rewardController.text != "") c.reward = int.parse(_rewardController.text);
      c.dueAt = _dueAt;
      c.latestAt = _latestAt;
      c = await _challengeService.save(widget.challenge);
      Navigator.pop(context, true);
    }
  }

  int _headTabCount = 0;
  _headTap() {
    ++_headTabCount;
    print('_headTap $_headTabCount');
    if (_headTabCount >= 10) {
      _headTabCount = 0;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Replace data with presentation data?'),
            actions: <Widget>[
              FlatButton(child: const Text('CANCEL'), onPressed: () => Navigator.of(context).pop()),
              FlatButton(child: const Text('REPLACE ALL DATA'), onPressed: () => Navigator.of(context).pop(true))
            ],
          );
        }
      ).then((value) async {
        if (value != null && value == true)  {
          await AppStateWidget.of(context).get<TestData>().deleteAll();
          await AppStateWidget.of(context).get<TestData>().generatePresentationData();
          Navigator.pop(context, true);
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _rewardController.dispose();
    _dueAtController.dispose();
    _latestUntilController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var c = widget.challenge;
    _challengeService ??= _challengeService = AppStateWidget.of(context).get<ChallengeService>();
    c.dueAt ??= c.dueAt = DateTimeUtil.clearTime(DateTime.now());
    c.latestAt ??= c.dueAt.add(Challenge.defaultChallengeWaitTime);

    final newChallenge = c.id == null;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Text(newChallenge ? 'Create Challenge': 'Edit Challenge'),
          onTap: _headTap,
        ),
        actions: <Widget>[
          FlatButton(child: Text(newChallenge ? 'CREATE' : 'UPDATE'), onPressed: _save)
        ]
      ),
      // https://medium.com/flutterpub/create-beautiful-forms-with-flutter-47075cfe712
      body: InputForm(
        formKey: _formKey,
        children: <Widget>[
          TextFormField(
            autofocus: true,
            inputFormatters: [LengthLimitingTextInputFormatter(Challenge.NAME_LENGTH)],
            controller: _nameController,
            validator: (String v) => v.isNullOrEmpty ? 'Enter a challenge name' : null,
            decoration: new InputDecoration(
              // icon: Icon(Icons.thumb_up, color: Colors.lightGreen),
              hintText: "What is your Challenge ...?",
              labelText: "Challenge Name"
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (v) {
              FocusScope.of(context).nextFocus();
            },
          ),

          TextFormField(
            controller: _dueAtController,
            onTap: () => _pickDueAt(c, context),
            readOnly: true,
            decoration: new InputDecoration(
              icon: Icon(Icons.today),
              labelText: "Due until",
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
          ),

          TextFormField(
            controller: _latestUntilController,
            onTap: () => _pickLatestAt(c, context),
            readOnly: true,
            decoration: new InputDecoration(
              icon: Icon(Icons.today),
              labelText: "Latest until",
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
          ),

          TextFormField(
            controller: _rewardController,
            validator: (String v) => v.isNullOrEmpty ? 'Enter reward points' : null,
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            decoration: new InputDecoration(
                icon: MyStyle.COST_ICON,
                hintText: "How many points should be rewarded?",
                labelText: "Reward"
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (v) => _save()
          ),
        ],
      )
    );
  }

  void _pickLatestAt(Challenge c, BuildContext context) {
    showDatePicker(context: context, initialDate: _latestAt, firstDate: _dueAt, lastDate: DateTime.now().add(Duration(days: 365)))
        .then((date) {
      if (date != null) {
        _latestUntilController.text = DateTimeUtil.formatDate(date);
        _latestAt = date;
        FocusScope.of(context).nextFocus();
      }
    });
  }

  void _pickDueAt(Challenge c, BuildContext context) {
    var now = DateTime.now();
    showDatePicker(context: context, initialDate: _dueAt, firstDate: now.isAfter(_dueAt) ? _dueAt : now, lastDate: now.add(Duration(days: 365)))
        .then((date) {
      if (date != null) {
        _dueAt = date;
        _dueAtController.text = DateTimeUtil.formatDate(date);
        if (date.isAfter(_latestAt)) {
          _latestAt = _dueAt;
          _latestUntilController.text = DateTimeUtil.formatDate(date);
        }
        FocusScope.of(context).nextFocus();
      }
    });
  }
}