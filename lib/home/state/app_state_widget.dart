import 'package:flutter/material.dart';
import 'package:flutterapp/container/app_context.dart';

///
/// Provides the AppContext
/// @see https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html
///
class AppStateWidget extends StatefulWidget {
  final AppContext context;
  final Widget child;

  AppStateWidget({Key key, @required this.context, @required this.child}) : super(key: key);

  static AppContext of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedDiContainer>().context;
  }

  @override
  _AppStateWidgetState createState() => _AppStateWidgetState();
}

class _AppStateWidgetState extends State<AppStateWidget> {
  @override
  Widget build(BuildContext context) {
    return _InheritedDiContainer(context: widget.context, child: widget.child);
  }
  @override
  void dispose() {
    super.dispose();
    widget.context.close();
  }
}

class _InheritedDiContainer extends InheritedWidget {

  final AppContext context;

  _InheritedDiContainer({Key key, @required this.context, @required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => this != oldWidget;
}