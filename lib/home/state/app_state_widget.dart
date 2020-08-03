import 'package:flutter/material.dart';
import 'package:challengeapp/container/app_context.dart';
import 'package:challengeapp/log/logger.dart';

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
    widget.context.close();
    super.dispose();
  }
}

class _InheritedDiContainer extends InheritedWidget {
  static final Logger _log = LoggerFactory.get<AppStateWidget>();
  final AppContext context;

  _InheritedDiContainer({Key key, @required this.context, @required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    bool result;
    if (oldWidget is _InheritedDiContainer) {
      result = oldWidget.context != this.context;
    } else {
      result = this != oldWidget;
    }
    if (result) _log.debug('rebuild triggered...');
    return result;
  }
}