import 'package:flutter/widgets.dart';

typedef BeanFactory<T> = T Function(DiContainer container);

class DiContainer {
  /// stores all [BeanFactory]s that get registered by Type
  final _rattlingerFactory = Map<Type, BeanFactory>();
  final _rattlinger = Map<Type, dynamic>();

  T get<T>() {
    var result = _rattlinger[T];
    if (result == null) {
      var factory = _rattlingerFactory[T];
      assert(() {
        if (factory == null) {
          throw FlutterError('No Bean nor Factory of type ${T.toString()} is registered.');
        }
        return true;
      }());
      result = factory(this);
      _rattlinger[T] = result;
      _rattlingerFactory[T] = null; // remove factory
    }
    return result;
  }

  void add<T>(T bean) {
    _rattlinger[T] = bean;
  }
  void addFactory<T>(BeanFactory<T> beanFactory) {
    _rattlingerFactory[T] = beanFactory;
  }
}