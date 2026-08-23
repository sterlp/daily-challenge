import 'package:challengeapp/challengelist/i18n/challengelist_localization.dart';
import 'package:challengeapp/i18n/challenge_localization_delegate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

abstract class AbstractPageModel {
  final WidgetTester tester;
  final ChallengeLocalizations i18n = ChallengeLocalizations(
    const Locale('en'),
  );
  final ChallengeListLocalizations challengeI18n = ChallengeListLocalizations(
    const Locale('en'),
  );

  AbstractPageModel(this.tester);
}
