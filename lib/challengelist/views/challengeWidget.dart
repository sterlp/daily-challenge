import 'package:flutter/material.dart';
import 'package:flutterapp/challengelist/models/challengeModel.dart';
import 'package:flutterapp/challengelist/views/rewardView.dart';
import 'package:flutterapp/util/date.dart';

typedef ChallengeChecked = void Function(Challenge challenge, bool checked);

class ChallengeWidget extends StatelessWidget {
  static const _overDueStyle = TextStyle(color: Colors.pink);
  static const _notOpenTextStyle = TextStyle(decoration: TextDecoration.lineThrough);
  final Challenge challenge;
  final ChallengeChecked onChecked;

  const ChallengeWidget({Key key, @required this.challenge, this.onChecked}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var done = challenge.isDone;
    var failed = challenge.isFailed;
    return CheckboxListTile(
          onChanged: onChecked == null ? null : (v) => onChecked.call(challenge, v),
          value: done,
          secondary: RewardWidget(reward: challenge.reward, status: challenge.status),
          subtitle: done
              ? Text('Done ' + DateTimeUtil.format(challenge.doneAt, Challenge.doneFormat))
              : failed ?
              Text('Failed since ' + DateTimeUtil.format(challenge.latestAt, Challenge.dueFormat), style: challenge.isOverdue ? _overDueStyle : null)
              : Text('Due until ' + DateTimeUtil.format(challenge.dueAt, Challenge.dueFormat), style: challenge.isOverdue ? _overDueStyle : null),
          title: Text(challenge.name, style: done || failed ? _notOpenTextStyle : null));
  }
}
