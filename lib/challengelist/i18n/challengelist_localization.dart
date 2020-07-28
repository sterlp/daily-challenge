import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutterapp/common/common_types.dart';
import 'package:flutterapp/i18n/app_localizations_delegate.dart';
import 'package:flutterapp/i18n/i18n_types.dart';

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

  //-- challenge page
  String get createChallengeHeader => 'Create Challenge';
  String get updateChallengeHeader => 'Update Challenge';
  String editChallengeHeader(bool create) => create ? createChallengeHeader : updateChallengeHeader;

  IFormField get challengeName => const SimpleFormField('Challenge Name', 'What is your Challenge...?', 'Enter a challenge name');
  IFormField get challengeDueAt => const SimpleFormField('Due at', 'Then do you plan to do this Challenge?', 'Enter due date');
  IFormField get challengeLatestAt => const SimpleFormField('Fail on', 'When should the Challenge fail? You will lose points!');
  IFormField get challengeReward => const SimpleFormField('Reward', 'How many points should be rewarded?', 'Enter reward points', MyStyle.COST_ICON);
}

class ChallengeListLocalizationsDE extends ChallengeListLocalizations {
  ChallengeListLocalizationsDE(Locale locale) : super(locale);

  @override
  String get newChallengeButton => 'Neue Challenge';
  @override
  String challengeWillFail(Duration duration) => 'Wird in ${duration.inDays} Tagen fehlschlagen.';

  //-- challenge page
  String get createChallengeHeader => 'Neue Challenge';
  String get updateChallengeHeader => 'Challenge aktualisieren';

  IFormField get challengeName => const SimpleFormField('Challenge Name', 'Was ist Deine Herausforderung...?', 'Gib einen Challenge-Namen ein');
  IFormField get challengeDueAt => const SimpleFormField('Fällig am', 'Wann planst Du das zu tun?', 'Gin ein Fälligkeitsdatum ein');
  IFormField get challengeLatestAt => const SimpleFormField('Fehlschlag am', 'Wann soll die Challenge fehlschlagen? Du verlierst Punkte!');
  IFormField get challengeReward => const SimpleFormField('Lohn', 'Wieviele Punkte bringt die Challenge?', 'Gib an wieviele Punkte die Challenge wert ist', MyStyle.COST_ICON);
}