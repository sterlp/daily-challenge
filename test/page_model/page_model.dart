import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/challengelist/i18n/challengelist_localization.dart';
import 'package:flutterapp/i18n/challenge_localization_delegate.dart';

abstract class AbstractPageModel {
  final WidgetTester tester;
  final ChallengeLocalizations i18n = ChallengeLocalizations(Locale('en'));
  final ChallengeListLocalizations challengeI18n = ChallengeListLocalizations(Locale('en'));

  AbstractPageModel(this.tester);
}