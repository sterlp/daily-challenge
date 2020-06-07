import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/util/data.dart';

enum Foo {
  one, two
}

void main() {
  void add<T>(Map<dynamic, dynamic> m, T v) {
    m[T] = v;
  }

  test('ParserUtil value of enum', () {
    expect(ParserUtil.valueOfEnum(Foo.one), 'one');
    expect(ParserUtil.valueOfEnum(null), null);
  });

  test('ParserUtil value of enum', () {
    expect(ParserUtil.parseEnumString(Foo.values, 'one'), Foo.one);
    expect(ParserUtil.parseEnumString(Foo.values, 'oneee'), null);
    expect(ParserUtil.parseEnumString(null, 'one'), null);
    expect(ParserUtil.parseEnumString(Foo.values, null), null);

    expect(ParserUtil.parseEnumStringWithDefault(Foo.values, null, Foo.two), Foo.two);
    expect(ParserUtil.parseEnumStringWithDefault(Foo.values, 'one', Foo.two), Foo.one);
  });
}
