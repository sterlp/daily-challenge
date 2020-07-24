import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String caption;

  const LoadingWidget({Key key, this.caption = 'Loading ...'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                child: CircularProgressIndicator(strokeWidth: 6.0),
                height: 80,
                width: 80,
              ),
              SizedBox(height: 24),
              Text(caption, style: Theme.of(context).textTheme.headline5)
            ]
        )
    );
  }
}