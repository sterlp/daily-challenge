
import 'package:flutter/material.dart';

/// because flutter sucks we have to do this here ...
/// flutter doesn't allow access to to providers in the initState method and calls
/// didChangeDependencies randomly for no reason so we have to guard it.
/// Flutter error:
/// When an inherited widget changes, for example if the value of Theme.of() changes, its dependent widgets are rebuilt. If the dependent widget's reference to the inherited widget is in a constructor or an initState() method, then the rebuilt dependent widget will not reflect the changes in the inherited widget.
abstract class FixedState<T extends StatefulWidget> extends State<T> {
  bool _initNeeded = false;

  @protected
  @mustCallSuper
  @override
  void initState() {
    super.initState();
    _initNeeded = true;
  }

  @protected
  @mustCallSuper
  @override
  void didChangeDependencies() {
    if (_initNeeded) {
      _initNeeded = false;
      saveInitState();
    }
    super.didChangeDependencies();
  }

  /// use this method instead of [initState], it is called once after [didChangeDependencies]
  @protected
  void saveInitState() {}
}