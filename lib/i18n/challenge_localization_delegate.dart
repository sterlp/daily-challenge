import 'package:challengeapp/i18n/app_localizations_delegate.dart';
import 'package:challengeapp/util/date.dart';
import 'package:flutter/material.dart';

class _ChallengeLocalizationsDelegate
    extends AppLocalizationsDelegate<ChallengeLocalizations> {
  const _ChallengeLocalizationsDelegate();
  @override
  ChallengeLocalizations deLocale(Locale locale) =>
      ChallengeLocalizationsDE(locale);
  @override
  ChallengeLocalizations defaultLocale(Locale locale) =>
      ChallengeLocalizations(locale);
}

class ChallengeLocalizations {
  static const LocalizationsDelegate<ChallengeLocalizations> delegate =
      _ChallengeLocalizationsDelegate();
  final Locale locale;

  ChallengeLocalizations(this.locale);

  String get appName => 'Challenge Yourself';

  String get buttonUpdate => 'UPDATE';
  String get buttonCreate => 'CREATE';
  String buttonSave(bool newRecord) => newRecord ? buttonCreate : buttonUpdate;

  String get dateFormat => "EEEEE, dd LLLL";
  String get dateFormatTime => "EEEE, dd.MM 'at' h:mm a";

  String formatDate(DateTime? date) => date == null
      ? ''
      : DateTimeUtil.formatWithString(date, dateFormat, locale);
  String formatMonth(DateTime? date) => date == null
      ? ''
      : DateTimeUtil.formatWithString(date, "MMMM, yyyy", locale);

  String formatDateTime(DateTime? date) => date == null
      ? ''
      : DateTimeUtil.formatWithString(date, dateFormatTime, locale);

  String get challengeTab => 'Challenges';
  String get rewardTab => 'Rewards';
  String get historyTab => 'History';
}

// ignore: camel_case_types
class ChallengeLocalizationsDE extends ChallengeLocalizations {
  ChallengeLocalizationsDE(super.locale);

  @override
  String get dateFormatTime => "EEEE, dd.MM 'um' H:mm 'Uhr'";

  @override
  String get buttonUpdate => 'AKTUALISIEREN';
  @override
  String get buttonCreate => 'ERSTELLEN';

  @override
  String get rewardTab => 'Belohnungen';
}
