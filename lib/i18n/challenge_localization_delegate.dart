import 'package:flutter/material.dart';
import 'package:flutterapp/i18n/app_localizations_delegate.dart';
import 'package:flutterapp/util/date.dart';

class _ChallengeLocalizationsDelegate extends AppLocalizationsDelegate<ChallengeLocalizations> {
  const _ChallengeLocalizationsDelegate();
  @override
  ChallengeLocalizations deLocale(Locale locale) => ChallengeLocalizationsDE(locale);
  @override
  ChallengeLocalizations defaultLocale(Locale locale) => ChallengeLocalizations(locale);
}

class ChallengeLocalizations {
  static const LocalizationsDelegate<ChallengeLocalizations> delegate = _ChallengeLocalizationsDelegate();
  final Locale locale;

  ChallengeLocalizations(this.locale);

  String get appName => 'Challenge Yourself';

  String get buttonUpdate => 'UPDATE';
  String get buttonCreate => 'CREATE';
  String buttonSave(bool newRecord) => newRecord ? buttonCreate : buttonUpdate;

  String get dateFormat => "EEEEE, LLLL dd";
  String get dateFormatTime => "EEEE, dd.MM 'at' h:mm a";

  String formatDate(DateTime date) => DateTimeUtil.formatWithString(date, dateFormat, locale);
  String formatMonth(DateTime date) => DateTimeUtil.formatWithString(date, "MMMM, yyyy", locale);

  String formatDateTime(DateTime date) => DateTimeUtil.formatWithString(date, dateFormatTime, locale);

  String get challengeTab => 'Challenges';
  String get rewardTab => 'Rewards';
  String get historyTab => 'History';

}

// ignore: camel_case_types
class ChallengeLocalizationsDE extends ChallengeLocalizations {
  ChallengeLocalizationsDE(Locale locale) : super(locale);

  String get dateFormatTime => "EEEE, dd.MM 'um' H:mm 'Uhr'";

  @override
  String get buttonUpdate => 'AKTUALISIEREN';
  @override
  String get buttonCreate => 'ERSTELLEN';

  String get rewardTab => 'Belohnungen';
}