import 'package:challengeapp/log/logger.dart';
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';

///
/// Provides the AppContext
/// @see https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html
/// @deprecated
@Deprecated('Using the Flutter AppState is harmful.')
class AppStateWidget extends StatefulWidget {
  final AppContainer context;
  final Widget child;

  @Deprecated('Using the Flutter AppState is harmful.')
  const AppStateWidget({super.key, required this.context, required this.child});

  static AppContainer of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedDiContainer>()!
        .context;
  }

  @override
  _AppStateWidgetState createState() => _AppStateWidgetState();
}

class _AppStateWidgetState extends State<AppStateWidget> {
  @override
  Widget build(BuildContext context) {
    return _InheritedDiContainer(widget.context, child: widget.child);
  }

  @override
  void dispose() {
    widget.context.close();
    super.dispose();
  }
}

class _InheritedDiContainer extends InheritedWidget {
  static final Logger _log = LoggerFactory.get<AppStateWidget>();
  final AppContainer context;

  const _InheritedDiContainer(this.context, {required super.child});

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    bool result;
    if (oldWidget is _InheritedDiContainer) {
      result = oldWidget.context != context;
    } else {
      result = this != oldWidget;
    }
    if (result) _log.debug('rebuild triggered...');
    return result;
  }
}
