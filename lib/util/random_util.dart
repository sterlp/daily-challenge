import 'dart:math';

class RandomUtil {
  static final _random = Random();
  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  static int randomInt([int max = 2147483647]) => _random.nextInt(max);

  static String randomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_random.nextInt(_chars.length))));
}