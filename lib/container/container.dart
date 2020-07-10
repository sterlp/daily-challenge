import 'package:flutter/widgets.dart';
import 'package:flutterapp/container/containerModel.dart';
import 'dart:developer' as developer;

typedef BeanFactory<T> = T Function(DiContainer container);

class DiContainer with Closeable {
  /// stores all [BeanFactory]s that get registered by Type
  final _rattlingerFactory = Map<Type, BeanFactory>();
  final _rattlinger = Map<Type, dynamic>();

  /// The amount of beans and factories registered
  int get size => _rattlingerFactory.length + _rattlinger.length;

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

  DiContainer add<T>(T bean) {
    _rattlinger[T] = bean;
    return this;
  }
  DiContainer addFactory<T>(BeanFactory<T> beanFactory) {
    _rattlingerFactory[T] = beanFactory;
    return this;
  }

  @override
  void close() {
    _rattlingerFactory.clear();
    _rattlinger.forEach((key, value) {
      try {
        if(value is Closeable) value.close();
      } catch(e) {
        developer.log('failed to close service', name: value.toString(), error: e);
      }
    });
    _rattlinger.clear();
  }
}