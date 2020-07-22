import 'package:flutter/widgets.dart';
import 'package:flutterapp/container/app_context_model.dart';
import 'package:flutterapp/log/logger.dart';

typedef BeanFactory<T> = T Function(AppContext container);

class AppContext with Closeable {
  static final Logger _log = LoggerFactory.get<AppContext>();
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

  AppContext add<T>(T bean) {
    _rattlinger[T] = bean;
    return this;
  }
  AppContext addFactory<T>(BeanFactory<T> beanFactory) {
    _rattlingerFactory[T] = beanFactory;
    return this;
  }

  @override
  Future<void> close() async {
    _log.info('app context is shutting down.');
    _rattlingerFactory.clear();
    final toClean = _rattlinger.values.toList();
    _rattlinger.clear();

    for (int i = 0; i < toClean.length; ++i) {
      final value = toClean[i];
      try {
        if (value is Closeable) await value.close();
      } catch(e) {
        _log.warn('failed to close service name: ${value.toString()}, error: $e');
      }
    }
  }
}