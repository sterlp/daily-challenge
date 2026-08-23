import 'package:challengeapp/common/model/abstract_entity.dart';
import 'package:flutter_test/flutter_test.dart';

class _Foo extends AbstractEntity {}

class _Bar extends AbstractEntity {}

void main() {
  test('Test operator==', () {
    final _Foo f1 = _Foo();
    final _Foo f2 = _Foo();

    expect(f1 == f2, false);

    f1.id = 1;
    f2.id = 1;
    expect(f1 == f2, true);

    f1.id = 1;
    f2.id = 2;
    expect(f1 == f2, false);
  });
  test('Test operator== different type', () {
    final _Foo f = _Foo();
    f.id = 1;
    final _Bar b = _Bar();
    b.id = 1;

    expect(f == b, false);
  });
}
