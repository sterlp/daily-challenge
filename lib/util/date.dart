import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

///
/// var from = DateTime(dateTime.year, dateTime.month, dateTime.day);
//  var to = DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
class DateTimeUtil {
  DateTimeUtil._();

  static final Map<String, DateFormat> _formatterCache = Map();

  static DateTime midnight(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
  }
  static DateTime clearTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
  static String format(DateTime d, DateFormat f) {
    if (d == null) return "";
    else return f.format(d);
  }

  static String formatWithString(DateTime date, String format, Locale locale) {
    DateFormat f = _formatterCache[format];
    if (f == null) {
      f = DateFormat(format, locale.languageCode);
      _formatterCache[format] = f;
    }
    return DateTimeUtil.format(date, f);
  }
}