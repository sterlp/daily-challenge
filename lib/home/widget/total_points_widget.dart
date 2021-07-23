import 'package:challengeapp/common/common_types.dart';
import 'package:flutter/material.dart';

/// Show the total earned points
class TotalPointsWidget extends StatefulWidget {
  final ValueNotifier<int> points;

  TotalPointsWidget(this.points, {Key key}) : super(key: key);

  @override
  _TotalPointsWidgetState createState() => _TotalPointsWidgetState();
}

class _TotalPointsWidgetState extends State<TotalPointsWidget> with SingleTickerProviderStateMixin {

  int _oldValue = 0;

  TextStyle _positive;
  static const TextStyle _negative = TextStyle(color: MyStyle.POSITIVE_BUDGET_COLOR, fontWeight: FontWeight.w600);

  @override
  void didChangeDependencies() {
    _positive = TextStyle(color: Theme.of(context).errorColor, fontWeight: FontWeight.w600);
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: widget.points,
        builder: (context, total, _) {
          Widget result;
          if (total != null) {
            TextStyle style;
            if (total < 0) style = _positive;
            else if (total > 0) style = _negative;

            result = Row(
              children: <Widget>[
                MyStyle.COST_ICON,
                Padding(
                  padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween<double>(begin: _oldValue.toDouble(), end: total.toDouble()),
                    builder: (context, value, child) => Text(value.toInt().toString(), style: style, textScaleFactor: 1.4),
                    onEnd: () => _oldValue = total,
                  )
                )
              ]
            );
          } else {
            result = CircularProgressIndicator();
          }
          return Container(child: result, height: 32);
        }
    );
  }
}