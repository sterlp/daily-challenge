import 'package:challengeapp/common/common_types.dart';
import 'package:challengeapp/reward/model/reward_model.dart';
import 'package:flutter/material.dart';


/// Shows a buy dialog and returns the reward
/// returns the user selection true or false if to buy or not.
Future<bool> showBuyRewardDialog(BuildContext context, Reward r, int totalCredit) async {
  final bodyStyle = Theme.of(context).textTheme.bodyText1;

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Buy Reward'),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                    style: bodyStyle,
                    text: 'Do you really want to spend ',
                    children: [
                      WidgetSpan(
                        child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(MyStyle.COST_ICON.icon, color: MyStyle.COST_ICON.color, size: bodyStyle.fontSize)),
                      ),
                      TextSpan(text: r.cost.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' for '),
                      TextSpan(text: r.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '?'),
                    ]
                ),
              ),
              RichText(
                text: TextSpan(
                    style: bodyStyle,
                    text: 'You still have ',
                    children: [
                      WidgetSpan(
                        child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(Icons.star, color: Colors.amber, size: bodyStyle.fontSize)),
                      ),
                      TextSpan(text: totalCredit.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' left.'),
                    ]
                ),
              ),
            ]
        ),
        actions: <Widget>[
          FlatButton(child: const Text('CANCEL'), onPressed: () => Navigator.of(context).pop(false)),
          FlatButton(child: const Text('CONFIRM'), onPressed: () => Navigator.of(context).pop(true))
        ],
      );
    },
  );
}

