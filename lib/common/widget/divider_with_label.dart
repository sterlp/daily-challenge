

import 'package:flutter/material.dart';

class DividerWithLabel extends StatelessWidget {
  final String label;
  final double indent;
  final double endIndent;
  final double thickness;

  const DividerWithLabel(this.label, {Key key, this.indent = 8.0, this.endIndent = 8.0, this.thickness = 3.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Divider(thickness: thickness, indent: indent, endIndent: 8)
        ),
        Text(label, style: Theme.of(context).textTheme.headline6),
        Expanded(
          child: Divider(thickness: thickness, indent: 8, endIndent: endIndent)
        ),
      ]
    );
  }
}

