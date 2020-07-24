import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/challengelist/service/challenge_service.dart';
import 'package:flutterapp/common/common_types.dart';
import 'package:flutterapp/common/widget/input_form.dart';
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
  DateTime _latestUntil;

  ChallengeService _challengeService;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_valueChanged);
    _rewardController.addListener(_valueChanged);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _challengeService ??= AppStateWidget.of(context).get<ChallengeService>();
    });
    final c = widget.challenge;
    _nameController.text = c.name;
    _rewardController.text = c.reward == null ? null : c.reward.toString();

    _dueAt = c.dueAt;
    _dueAtController.text = DateTimeUtil.formatDate(_dueAt);
    _latestUntil = c.latestAt;
    _latestUntilController.text = DateTimeUtil.formatDate(_latestUntil);
  }

  void _valueChanged() {
    var c = widget.challenge;
    c.name = _nameController.text;
    if (_rewardController.text != "") c.reward = int.parse(_rewardController.text);
    // dev.log('_valueChanged $c');
  }
  _save() async {
    if (_formKey.currentState.validate()) {
      _valueChanged();
      var c = await _challengeService.save(widget.challenge);
      Navigator.pop(context, c);
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
        title: Text(newChallenge ? 'Create Challenge': 'Edit Challenge'),
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
              prefixIcon: Icon(Icons.today),
              labelText: "Due until",
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
          ),

          TextFormField(
            controller: _latestUntilController,
            onTap: () {
              showDatePicker(context: context, initialDate: _latestUntil, firstDate: _dueAt, lastDate: DateTime.now().add(Duration(days: 365)))
                  .then((date) {
                if (date != null) {
                  _latestUntilController.text = DateTimeUtil.formatDate(date);
                  _latestUntil = date;
                  FocusScope.of(context).nextFocus();
                }
              });
            },
            readOnly: true,
            decoration: new InputDecoration(
              prefixIcon: Icon(Icons.today),
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
                prefixIcon: MyStyle.COST_ICON,
                hintText: "Enter the value of this challenge",
                labelText: "Reward"
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (v) => _save()
          ),
        ],
      )
    );
  }

  void _pickDueAt(Challenge c, BuildContext context) {
    var now = DateTime.now();
    showDatePicker(context: context, initialDate: _dueAt, firstDate: now, lastDate: now.add(Duration(days: 365)))
        .then((date) {
      if (date != null) {
        _dueAt = date;
        _dueAtController.text = DateTimeUtil.formatDate(date);
        if (date.isAfter(_latestUntil)) {
          _latestUntil = _dueAt;
          _latestUntilController.text = DateTimeUtil.formatDate(date);
        }
        FocusScope.of(context).nextFocus();
      }
    });
  }
}