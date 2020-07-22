import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/challengelist/service/challenge_service.dart';
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
  ChallengeService _challengeService;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_valueChanged);
    _rewardController.addListener(_valueChanged);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _challengeService = AppStateWidget.of(context).get<ChallengeService>();
    });

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
  }
  @override
  Widget build(BuildContext context) {
    var c = widget.challenge;
    if (_challengeService == null) _challengeService = AppStateWidget.of(context).get<ChallengeService>();

    if (c.dueAt == null) c.dueAt = DateTimeUtil.clearTime(DateTime.now());
    if (c.latestAt == null) c.latestAt = c.dueAt.add(Challenge.defaultChallengeWaitTime);

    _nameController.text = c.name;
    _rewardController.text = c.reward == null ? 0 : c.reward.toString();
    return Scaffold(
      appBar: AppBar(
        title: Text(c.id != null ? 'Edit ${c.name}' : 'Create a new challenge'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save), onPressed: _save)
        ]
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _save,
          child: Icon(Icons.save)
      ),
      // https://medium.com/flutterpub/create-beautiful-forms-with-flutter-47075cfe712
      body: Form(key: _formKey, child:
        ListView(
          children: <Widget>[
            new ListTile(
              leading: _listIcon(Icon(Icons.thumb_up, color: Colors.lightGreen)),
              title: TextFormField(
                inputFormatters: [LengthLimitingTextInputFormatter(Challenge.NAME_LENGTH)],
                controller: _nameController,
                validator: (String v) => v.isNullOrEmpty ? 'Enter a challenge name' : null,
                decoration: new InputDecoration(
                  hintText: "Enter your challenge name",
                  labelText: "Challenge"
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (v) {
                  FocusScope.of(context).nextFocus();
                },
              ),
            ),
            new ListTile(
              leading: _listIcon(const Icon(Icons.star, color: Colors.amber)),
              title: TextFormField(
                controller: _rewardController,
                validator: (String v) => v.isNullOrEmpty ? 'Enter reward points' : null,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(
                    hintText: "Enter the value of this challenge",
                    labelText: "Reward"
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (v) {
                  FocusScope.of(context).nextFocus();
                },
              ),
            ),
            new ListTile(
              leading: Container(child: Icon(Icons.today), alignment: Alignment.center, height: 40, width: 20),
              title: Text('Due until'),
              subtitle: Text(Challenge.dueFormat.format(c.dueAt)),
              onTap: () {
                showDatePicker(context: context, initialDate: c.dueAt, firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 365)))
                  .then((value) {
                    if (value != null) {
                      setState(() {
                        c.dueAt = value;
                        if (value.isAfter(c.latestAt)) {
                          c.latestAt = c.dueAt;
                        }
                      });
                    }
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.today),
              title: Text('Latest until'),
              subtitle: Text(Challenge.dueFormat.format(c.latestAt)),
              onTap: () {
                showDatePicker(context: context, initialDate: c.latestAt, firstDate: c.dueAt, lastDate: DateTime.now().add(Duration(days: 365)))
                  .then((value) {
                    if (value != null) {
                      setState(() {
                        c.latestAt = value;
                      });
                    }
                });
              },
            ),
          ],
        ),
      )
    );
  }

  Widget _listIcon(Icon icon) {
    return Container(child: icon, alignment: Alignment.center, height: 40, width: 20);
  }
}