
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

class ChallengeLocalizationsDelegate extends LocalizationsDelegate<ChallengeLocalizations> {
  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'de' || locale.languageCode == 'en';
  }

  @override
  Future<ChallengeLocalizations> load(Locale locale) async {
    ChallengeLocalizations result;
    print('ChallengeLocalizations $locale');
    if (locale.languageCode == 'de') {
      result = ChallengeLocalizations_DE();
    }
    else result = ChallengeLocalizations();
    return Future.value(result);
  }

  @override
  bool shouldReload(LocalizationsDelegate<ChallengeLocalizations> old) => false;
}

class ChallengeLocalizations {
  String get appName => 'Challenge Yourself';

  String get timeAt => "at";

  String get buttonUpdate => 'UPDATE';
  String get buttonCreate => 'CREATE';
  String buttonSave(bool newRecord) => newRecord ? buttonCreate : buttonUpdate;

  String get newChallengeButton => 'New Challenge';


}

// ignore: camel_case_types
class ChallengeLocalizations_DE extends ChallengeLocalizations {
  String get timeAt => "um";

  @override
  String get buttonUpdate => 'AKTUALISIEREN';
  @override
  String get buttonCreate => 'ERSTELLEN';

  @override
  String get newChallengeButton => 'Neue Challenge';



}