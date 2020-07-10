import 'package:flutter/material.dart';

/// Show the total earned points
class TotalPointView extends StatefulWidget {
  final Stream<int> points;

  TotalPointView(this.points, {Key key}) : super(key: key);

  @override
  _TotalPointViewState createState() => _TotalPointViewState();
}

class _TotalPointViewState extends State<TotalPointView> {
  _TotalPointViewState();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: widget.points,
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