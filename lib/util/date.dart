import 'package:intl/intl.dart';

///
/// var from = DateTime(dateTime.year, dateTime.month, dateTime.day);
//  var to = DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
class DateTimeUtil {
  static DateTime midnight(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
  }
  static DateTime clearTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static String format(DateTime d, DateFormat f) {
    if (d == null) return "";
    else return f.format(d);
  }
}