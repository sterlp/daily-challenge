import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:challengeapp/common/common_types.dart';
import 'package:challengeapp/i18n/app_localizations_delegate.dart';
import 'package:challengeapp/i18n/i18n_types.dart';

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

  String challengeWillFail(Duration duration) => duration.inDays == 0
      ? 'Today is your last chance to finish this challenge.'
      : 'Will fail in ${duration.inDays} day(s).';
  String dueUntil(String date) => 'Due on $date';
  String doneAt(String date) => 'Done on $date';
  String failedSince(String date) => 'Failed since $date';


  //-- challenge page
  String get createChallengeHeader => 'Create Challenge';
  String get updateChallengeHeader => 'Update Challenge';
  String editChallengeHeader(bool create) => create ? createChallengeHeader : updateChallengeHeader;

  IFormField get challengeName => const SimpleFormField('Challenge Name', 'What is your Challenge...?', 'Enter a challenge name');
  IFormField get challengeDueAt => const SimpleFormField('Due at', 'Then do you plan to do this Challenge?', 'Enter due date');
  IFormField get challengeLatestAt => const SimpleFormField('Fail on', 'When should the Challenge fail? You will lose points!');
  IFormField get challengeReward => const SimpleFormField('Reward', 'How many points should be rewarded?', 'Enter reward points', MyStyle.COST_ICON);

  // Reward Page
  String lastPurchase(String date) =>  'Last rewarded on $date';
}

class ChallengeListLocalizationsDE extends ChallengeListLocalizations {
  ChallengeListLocalizationsDE(Locale locale) : super(locale);

  @override
  String get newChallengeButton => 'Neue Challenge';
  @override
  String challengeWillFail(Duration duration) => duration.inDays == 0
    ? 'Heute ist die letzte Chance diese Challenge zu beenden!'
    : 'Wird in ${duration.inDays} Tagen fehlschlagen.';

  @override
  String dueUntil(String date) => 'Am $date fällig';
  @override
  String doneAt(String date) => 'Am $date erledigt';
  @override
  String failedSince(String date) => 'Fehlgeschlagen seit $date';

  //-- challenge page
  @override
  String get createChallengeHeader => 'Neue Challenge';
  @override
  String get updateChallengeHeader => 'Challenge aktualisieren';


  @override
  IFormField get challengeName => const SimpleFormField('Challenge Name', 'Was ist Deine Herausforderung...?', 'Gib einen Challenge-Namen ein');
  @override
  IFormField get challengeDueAt => const SimpleFormField('Fällig am', 'Wann planst Du das zu tun?', 'Gin ein Fälligkeitsdatum ein');
  @override
  IFormField get challengeLatestAt => const SimpleFormField('Fehlschlag am', 'Wann soll die Challenge fehlschlagen? Du verlierst Punkte!');
  @override
  IFormField get challengeReward => const SimpleFormField('Punkte', 'Wieviele Punkte bringt die Challenge?', 'Gib an wieviele Punkte die Challenge wert ist', MyStyle.COST_ICON);


  // Reward Page
  String lastPurchase(String date) =>  'Letztmalig belohnt am $date';
}