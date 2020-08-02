import 'dart:developer';

import 'package:flutter/foundation.dart';

class LoggerFactory {
  static Logger get<T>() {
    return getWithName(T.toString());
  }
  static Logger getWithName(String name) {
    return Logger(name);
  }
}

class Logger {
  final String _name;

  Logger(this._name);

  num _syncTime;
  String _syncString;

  error(String message, dynamic e) {
    print('[ERROR]  $_name: $message -> $e');
  }
  warn(String message) {
    print('[WARN]  $_name: $message');
  }
  info(String message) {
    if (kDebugMode) print('[INFO]  $_name: $message');
  }
  debug(String message) {
    if (kDebugMode) print('[DEBUG] $_name: $message');
  }

  startSync(String name) {
    if (kDebugMode) {
      Timeline.startSync(name);
      _syncTime = DateTime.now().millisecondsSinceEpoch;
      _syncString = name;
    }
  }

  /// Finishes and logs the time, override the message with [message] if needed.
  finishSync([String message]) {
    if (kDebugMode) {
      if (_syncString == null || _syncTime == null) {
        warn('finishSync without startSync!');
      } else {
        if (message != null) _syncString = message;
        _syncTime = DateTime.now().millisecondsSinceEpoch - _syncTime;
        debug('$_syncString executed in ${_syncTime}ms.');
      }
      Timeline.finishSync();
      _syncString = null;
      _syncTime = null;
    }
  }
}