import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService with Closeable {
  final ValueNotifier isDarkMode = ValueNotifier(true);

  Future<ConfigService> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkMode.value = (prefs.getBool('challenge_app_isDarkMode') ?? true);

    isDarkMode.addListener(_newDarkModeValue);
    return this;
  }

  void _newDarkModeValue() async {
    SharedPreferences.getInstance().then((pref) => pref.setBool('challenge_app_isDarkMode', isDarkMode.value));
  }

  @override
  Future<void> close() {
    isDarkMode.dispose();
    return SynchronousFuture(null);
  }
}