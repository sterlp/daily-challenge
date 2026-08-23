import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String caption;

  const LoadingWidget({super.key, this.caption = 'Loading ...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Stack(
            children: [
              SizedBox(
                child: CircularProgressIndicator(strokeWidth: 6.0),
                height: 80,
                width: 80,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(caption, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}
