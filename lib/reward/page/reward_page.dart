import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:challengeapp/common/common_types.dart';
import 'package:challengeapp/common/widget/input_form.dart';
import 'package:challengeapp/home/state/app_state_widget.dart';
import 'package:challengeapp/reward/model/reward_model.dart';
import 'package:challengeapp/reward/service/reward_service.dart';
import 'package:challengeapp/util/strings.dart';

/// https://dartpad.dev/embed-flutter.html?id=7a32619ce3c99711dc7e2fb8d235a635
class RewardPage extends StatefulWidget {
  final Reward reward;
  RewardPage({Key key, this.reward}) : super(key: key);

  @override
  _RewardPageState createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  RewardService _rewardService;

  void _save() async {
    if (_formKey.currentState.validate()) {
      widget.reward.cost = int.parse(_costController.text);
      widget.reward.name = _nameController.text;
      var c = await _rewardService.save(widget.reward);
      Navigator.pop(context, c);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _costController.text = widget.reward.cost == null ? null : widget.reward.cost.toString();
    _nameController.text = widget.reward.name;
  }

  @override
  Widget build(BuildContext context) {
    if (_rewardService == null) _rewardService = AppStateWidget.of(context).get<RewardService>();
    final bool newReward = widget.reward.id == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(newReward ? 'New Reward' : 'Edit Reward'),
        actions: <Widget>[
          FlatButton(child: Text(newReward ? 'CREATE' : 'UPDATE'), onPressed: _save)
        ]
      ),
      body: InputForm(
        formKey: _formKey,
        children: <Widget>[
          TextFormField(
            autofocus: true,
            inputFormatters: [LengthLimitingTextInputFormatter(Reward.NAME_LENGTH)],
            controller: _nameController,
            validator: (String v) => v.isNullOrEmpty ? 'Enter a reward name' : null,
            decoration: new InputDecoration(
                hintText: "What is your Reward ...?",
                labelText: "Reward Name",
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (v) => FocusScope.of(context).nextFocus()
          ),
          TextFormField(
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            controller: _costController,
            validator: (String v) => v.isNullOrEmpty ? 'Enter a reward cost' : null,
            textInputAction: TextInputAction.done,
            decoration: new InputDecoration(
              icon: MyStyle.COST_ICON,
              hintText: "What should the reward cost?",
              labelText: "Costs",
            ),
            keyboardType: TextInputType.number,
            onFieldSubmitted: (v) => _save()
          )
        ],
      )
    );
  }
}