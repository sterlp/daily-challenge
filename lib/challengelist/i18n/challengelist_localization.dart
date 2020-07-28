import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutterapp/i18n/app_localizations_delegate.dart';

class _ChallengeListLocalizationDelegate extends AppLocalizationsDelegate<ChallengeListLocalizations> {
  const _ChallengeListLocalizationDelegate();
  @override
  ChallengeListLocalizations deLocale(Locale locale) => ChallengeListLocalizationsDE(locale);
  @override
  ChallengeListLocalizations defaultLocale(Locale locale) => ChallengeListLocalizations(locale);
}

class ChallengeListLocalizations {
  static const LocalizationsDelegate<ChallengeListLocalizations> delegate = _ChallengeListLocalizationDelegate();
  final Locale locale;

  ChallengeListLocalizations(this.locale);

  String get newChallengeButton => 'New Challenge';

  String challengeWillFail(Duration duration) => 'Will fail in ${duration.inDays} day(s).';
}

class ChallengeListLocalizationsDE extends ChallengeListLocalizations {
  ChallengeListLocalizationsDE(Locale locale) : super(locale);

  @override
  String get newChallengeButton => 'Neue Challenge';
  @override
  String challengeWillFail(Duration duration) => 'Wird in ${duration.inDays} Tagen fehlschlagen.';
}