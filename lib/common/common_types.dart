import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/i18n/challenge_localization_delegate.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MyStyle {
  static const COST_ICON = const Icon(Icons.star, color: Colors.amber);
  static const GOAL_ICON = const Icon(MdiIcons.trophy, color: Colors.amber);

  static const POSITIVE_BUDGET_COLOR = Colors.green;
}


class MyFormatter {
  static final DateFormat dateTimeFormat = DateFormat("EEEE, dd.MM 'at' h:mm a");

  static final DateFormat _dateFormat = DateFormat("EEEE, dd.MM", 'de');
  static final DateFormat dateFormat = DateFormat("EEEEE, LLLL dd");

  // TODO move me maybe to i18n
  static String formatDateTime(BuildContext context, DateTime dateTime) {
    if (dateTime == null) return "";
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final i18n = Localizations.of<ChallengeLocalizations>(context, ChallengeLocalizations);

    return '${_dateFormat.format(dateTime)} ${i18n.timeAt} ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(dateTime))}';
  }
}
