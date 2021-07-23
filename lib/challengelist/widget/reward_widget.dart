import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/common/common_types.dart';
import 'package:flutter/material.dart';

// TODO rename me
class RewardWidget extends StatelessWidget {
  final int reward;
  final ChallengeStatus status;

  const RewardWidget({Key key, this.reward, this.status = ChallengeStatus.open}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon = MyStyle.ICON_PENDING_CHALLENGE;
    Color color = Colors.orange;
    final theme = Theme.of(context);
    if (status == ChallengeStatus.failed) {
      icon = MyStyle.ICON_FAILED_CHALLENGE;
      color = theme.errorColor;
    } else if (status == ChallengeStatus.done) {
      icon = MyStyle.ICON_DONE_CHALLENGE;
      color = MyStyle.POSITIVE_BUDGET_COLOR;
    }

    return SizedBox.fromSize(
      size: Size(56, 56), // button width and height
      child: ClipOval(
        child: Material(
          color: color, // button color
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon), // icon
              Text(reward.toString()), // text
            ],
          ),
        ),
      ),
    );
  }
}