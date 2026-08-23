import 'package:challengeapp/util/data.dart';
import 'package:flutter_test/flutter_test.dart';

enum Foo { one, two }

void main() {
  test('ParserUtil value of enum', () {
    expect(ParserUtil.valueOfEnum(Foo.one), 'one');
    expect(ParserUtil.valueOfEnum(null), null);
  });

  test('ParserUtil value of enum', () {
    expect(ParserUtil.parseEnumString(Foo.values, 'one'), Foo.one);
    expect(ParserUtil.parseEnumString(Foo.values, 'oneee'), null);
    expect(
      ParserUtil.parseEnumStringWithDefault(const <Foo>[], 'one', null),
      null,
    );
    expect(ParserUtil.parseEnumStringWithDefault(Foo.values, null, null), null);

    expect(
      ParserUtil.parseEnumStringWithDefault(Foo.values, null, Foo.two),
      Foo.two,
    );
    expect(
      ParserUtil.parseEnumStringWithDefault(Foo.values, 'one', Foo.two),
      Foo.one,
    );
  });
}
