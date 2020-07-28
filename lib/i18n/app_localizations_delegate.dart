import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutterapp/challengelist/i18n/challengelist_localization.dart';
import 'package:flutterapp/i18n/challenge_localization_delegate.dart';

// Consider https://pub.dev/packages/i18n
abstract class AppLocalizationsDelegate<T> extends LocalizationsDelegate<T> {
  static const List<LocalizationsDelegate<dynamic>> delegates = <LocalizationsDelegate<dynamic>>[
    ChallengeLocalizations.delegate,
    ChallengeListLocalizations.delegate,

    GlobalCupertinoLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];
  static const List<Locale> locales = [
    const Locale('en'),
    const Locale('de'),
  ];
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'de' || locale.languageCode == 'en';
  }

  @override
  Future<T> load(Locale locale) {
    T result;
    if (locale.languageCode == 'de') result = deLocale(locale);
    else result = defaultLocale(locale);
    return SynchronousFuture(result);
  }

  T defaultLocale(Locale locale);
  T deLocale(Locale locale);

  @override
  bool shouldReload(LocalizationsDelegate<T> old) => false;
}