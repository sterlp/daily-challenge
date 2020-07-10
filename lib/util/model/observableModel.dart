import 'dart:async';

class ObservableModel<T> {
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
    _value = newVal;
    _controller.sink.add(newVal);
  }

  close() {
    _controller.close();
  }
}