import 'package:flutter/material.dart';
import 'package:flutterapp/util/model/observable_model.dart';

/// Show the total earned points
class TotalPointsWidget extends StatefulWidget {
  final ObservableModel<int> points;

  TotalPointsWidget(this.points, {Key key}) : super(key: key);

  @override
  _TotalPointsWidgetState createState() => _TotalPointsWidgetState();
}

class _TotalPointsWidgetState extends State<TotalPointsWidget> {
  _TotalPointsWidgetState();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: widget.points.stream,
        initialData: widget.points.value,
        builder: (context, snapshot) {
          Widget result;
          if (snapshot.hasData) {
            final total = snapshot.data;
            TextStyle style;
            if (total < 0) style = TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600);
            else if (total > 0) style = TextStyle(color: Colors.green, fontWeight: FontWeight.w600);
            result = Row(
              children: <Widget>[
                Icon(Icons.star, color: Colors.amber),
                Padding(
                  padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                  child: Text(total.toString(), style: style, textScaleFactor: 1.2))
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