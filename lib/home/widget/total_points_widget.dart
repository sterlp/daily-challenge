import 'package:flutter/material.dart';
import 'package:flutterapp/common/common_types.dart';

/// Show the total earned points
class TotalPointsWidget extends StatefulWidget {
  final ValueNotifier<int> points;

  TotalPointsWidget(this.points, {Key key}) : super(key: key);

  @override
  _TotalPointsWidgetState createState() => _TotalPointsWidgetState();
}

class _TotalPointsWidgetState extends State<TotalPointsWidget> {
  _TotalPointsWidgetState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<int>(
        valueListenable: widget.points,
        builder: (context, total, _) {
          Widget result;
          if (total != null) {
            TextStyle style;
            if (total < 0) style = TextStyle(color: theme.errorColor, fontWeight: FontWeight.w600);
            else if (total > 0) style = TextStyle(color: MyStyle.POSITIVE_BUDGET_COLOR, fontWeight: FontWeight.w600);
            result = Row(
              children: <Widget>[
                MyStyle.COST_ICON,
                Padding(
                  padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                  child: AnimatedSwitcher(
                    transitionBuilder: (child, animation) => ScaleTransition(child: child, scale: animation),
                    duration: const Duration(milliseconds: 500),
                    child: Text(total.toString(), style: style, textScaleFactor: 1.4, key: ValueKey(total))
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