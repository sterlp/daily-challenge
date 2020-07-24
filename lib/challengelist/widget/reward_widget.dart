import 'package:flutter/material.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/common/common_types.dart';

// TODO rename me
class RewardWidget extends StatelessWidget {
  final int reward;
  final ChallengeStatus status;

  const RewardWidget({Key key, this.reward, this.status = ChallengeStatus.open}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.stars;
    Color color = Colors.orange;
    final theme = Theme.of(context);
    if (status == ChallengeStatus.failed) {
      icon = Icons.warning;
      color = theme.errorColor;
    } else if (status == ChallengeStatus.done) {
      icon = Icons.star;
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