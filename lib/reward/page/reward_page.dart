import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/common/common_types.dart';
import 'package:flutterapp/common/widget/input_form.dart';
import 'package:flutterapp/home/state/app_state_widget.dart';
import 'package:flutterapp/reward/model/reward_model.dart';
import 'package:flutterapp/reward/service/reward_service.dart';
import 'package:flutterapp/util/strings.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
    super.dispose();
    _nameController.dispose();
    _costController.dispose();
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
    final bool newReward = widget.reward != null;
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
                icon: MyStyle.GOAL_ICON,
                hintText: "Enter reward name",
                labelText: "Reward",
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
              hintText: "Enter the reward costs",
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