import 'package:flutter/material.dart';
import 'package:flutterapp/challengelist/models/challenge_model.dart';

class RewardWidget extends StatelessWidget {
  final int reward;
  final ChallengeStatus status;

  const RewardWidget({Key key, this.reward, this.status = ChallengeStatus.open}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.star;
    Color color = Colors.amber;

    if (status == ChallengeStatus.failed) {
      icon = Icons.warning;
      color = Colors.pinkAccent;
    } else if (status == ChallengeStatus.done) {
      icon = Icons.stars;
      color = Colors.greenAccent;
    }

    return SizedBox.fromSize(
      size: Size(56, 56), // button width and height
      child: ClipOval(
        child: Material(
          color: color, // button color
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon), // icon
                Text(reward.toString()), // text
              ],
            ),
          ),
        ),
      ),
    );
  }
}