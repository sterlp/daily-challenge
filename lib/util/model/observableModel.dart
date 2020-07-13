import 'dart:async';

import 'package:flutterapp/container/app_context_model.dart';

class ObservableModel<T> with Closeable {
  final StreamController<T> _controller = new StreamController<T>();
  Stream<T> _stream;
  T _value;

  ObservableModel() {
    _stream = _controller.stream.asBroadcastStream();
    _stream.listen((v) => _value = v);
  }

  Stream<T> get stream => _stream;
  get value => _value;

  set value(T newVal) {
    if (_value != newVal) {
      _value = newVal;
      _controller.sink.add(newVal);
    }
  }

  @override
  close() {
    _controller.close();
  }
}