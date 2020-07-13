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

  warn(String message) {
    print('[WARN]  $_name: $message');
  }
  info(String message) {
    print('[INFO]  $_name: $message');
  }
  debug(String message) {
    print('[DEBUG] $_name: $message');
  }
}