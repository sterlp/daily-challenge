import 'package:challengeapp/common/common_types.dart';
import 'package:challengeapp/reward/model/reward_model.dart';
import 'package:flutter/material.dart';

/// Shows a buy dialog and returns the reward
/// returns the user selection true or false if to buy or not.
Future<bool?> showBuyRewardDialog(
  BuildContext context,
  Reward r,
  int totalCredit,
) {
  final bodyStyle = Theme.of(context).textTheme.bodyLarge;

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Buy Reward'),
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
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        MyStyle.COST_ICON.icon,
                        color: MyStyle.COST_ICON.color,
                        size: bodyStyle!.fontSize,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: r.cost.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' for '),
                  TextSpan(
                    text: r.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: bodyStyle,
                text: 'You still have ',
                children: [
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: bodyStyle.fontSize,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: totalCredit.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' left.'),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('CONFIRM'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
}
