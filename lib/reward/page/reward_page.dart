import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  RewardService _rewardService;

  void _save() async {
    if (_formKey.currentState.validate()) {
      var c = await _rewardService.save(widget.reward);
      Navigator.pop(context, c);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _costController = TextEditingController();

    if (_rewardService == null) _rewardService = AppStateWidget.of(context).get<RewardService>();
    _costController.text = widget.reward.cost == null ? null : widget.reward.cost.toString();
    _nameController.text = widget.reward.name;

    return Scaffold(
      appBar: AppBar(
        title: Text('New Reward'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save), onPressed: _save)
        ]
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Save changes',
        onPressed: _save,
        child: Icon(Icons.save)
      ),
      body: Center(
        child: Shortcuts(
          shortcuts:  {
            // Pressing enter on the field will now move to the next field.
            LogicalKeySet(LogicalKeyboardKey.enter): Intent(NextFocusAction.key),
          },
          child: FocusTraversalGroup(
            child: Form(
              key: _formKey,
              autovalidate: true,
              onChanged: () {
                Form.of(primaryFocus.context).save();
                if (_costController.text.isNullOrEmpty) widget.reward.cost = null;
                else widget.reward.cost = int.parse(_costController.text);
                widget.reward.name = _nameController.text;
              },
              child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                  TextFormField(
                    inputFormatters: [LengthLimitingTextInputFormatter(Reward.NAME_LENGTH)],
                    controller: _nameController,
                    validator: (String v) => v.isNullOrEmpty ? 'Enter a reward name' : null,
                    decoration: new InputDecoration(
                        icon: Icon(MdiIcons.trophy, color: Colors.amber),
                        hintText: "Enter reward name",
                        labelText: "Reward"
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).nextFocus();
                    },
                  ),
                  TextFormField(
                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                    controller: _costController,
                    validator: (String v) => v.isNullOrEmpty ? 'Enter a reward cost' : null,
                    textInputAction: TextInputAction.done,
                    decoration: new InputDecoration(
                      icon: Icon(MdiIcons.cashMultiple, color: Colors.green),
                      hintText: "Enter the reward costs",
                      labelText: "Costs",
                    ),
                    keyboardType: TextInputType.number,
                  )
                ],
              )
            )
          )
        )
      )
    );
  }
}