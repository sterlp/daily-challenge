import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              Padding(child: Text('Loading ...', style: Theme.of(context).textTheme.headline4,), padding: EdgeInsets.all(16)),
            ]
        )
    );
  }
}