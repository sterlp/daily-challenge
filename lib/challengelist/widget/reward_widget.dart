import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/common/common_types.dart';
import 'package:flutter/material.dart';

// TODO rename me
class RewardWidget extends StatelessWidget {
  final int reward;
  final ChallengeStatus status;

  const RewardWidget({
    super.key,
    required this.reward,
    this.status = ChallengeStatus.open,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon = MyStyle.ICON_PENDING_CHALLENGE;
    Color color = Colors.orange;
    final theme = Theme.of(context);
    if (status == ChallengeStatus.failed) {
      icon = MyStyle.ICON_FAILED_CHALLENGE;
      color = theme.colorScheme.error;
    } else if (status == ChallengeStatus.done) {
      icon = MyStyle.ICON_DONE_CHALLENGE;
      color = MyStyle.POSITIVE_BUDGET_COLOR;
    }

    final circle = SizedBox.fromSize(
      size: const Size(56, 56), // button width and height
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

    if (status == ChallengeStatus.open) return circle;

    // celebrate the transition with an expanding, fading pulse ring
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => CustomPaint(
        foregroundPainter: _PulseRingPainter(t, color),
        child: child,
      ),
      child: circle,
    );
  }
}

class _PulseRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _PulseRingPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.shortestSide / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 * (1 - progress)
      ..color = color.withValues(alpha: 0.7 * (1 - progress));

    canvas.drawCircle(center, baseRadius * (1 + progress * 0.6), paint);
  }

  @override
  bool shouldRepaint(_PulseRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
