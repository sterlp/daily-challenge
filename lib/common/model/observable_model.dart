import 'dart:async';

import 'package:dependency_container/dependency_container.dart';

class ObservableModel<T> with Closeable {
  final StreamController<T> _controller = StreamController<T>();
  Stream<T> _stream;
  T _value;

  ObservableModel() {
    _stream = _controller.stream.asBroadcastStream();
    _stream.listen((v) => _value = v);
  }

  Stream<T> get stream => _stream;
  T get value => _value;

  set value(T newVal) {
    if (_value != newVal) {
      _value = newVal;
      _controller.sink.add(newVal);
    }
  }

  @override
  Future close() {
    return _controller.close();
  }
}