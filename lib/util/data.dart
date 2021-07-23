typedef DbRowMapper<T> = T Function(Map<String, dynamic> value);

class ParserUtil {
  static int dateToNumber(DateTime v) {
    if (v == null) return null;
    return v.millisecondsSinceEpoch;
  }
  static DateTime parseDate(dynamic v) {
    DateTime result;
    if (v == null) {
      result = null;
    } else if (v is DateTime) {
      result = v;
    } else {
      result = DateTime.fromMillisecondsSinceEpoch(v as int);
    }
    return result;
  }

  /// Returns the value of an ENUM as String, otherwise null.
  static String valueOfEnum(e) => e == null ? null : e.toString().split('.').last;
  /// Returns the first matching ENUM to the given String
  static T parseEnumString<T>(List<T> enumValues, String v) {
    return parseEnumStringWithDefault(enumValues, v, null);
  }
  /// Returns the first matching ENUM to the given String, otherwise the default value.
  static T parseEnumStringWithDefault<T>(List<T> enumValues, String v, T defaultValue) {
    if (v == null || enumValues == null || enumValues.isEmpty) return defaultValue;

    return enumValues.firstWhere((e) => valueOfEnum(e) == v, orElse: () => defaultValue);
  }


  static List<T> mapDbResult<T>(List<Map<String, dynamic>> dbValues, DbRowMapper<T> converter) {
    final result = <T>[];
    for (final values in dbValues) {
      result.add(converter(values));
    }
    return result;
  }
}