import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/util/model/observableModel.dart';

void main() {

  test('ObservableModel setter test', () {
    var v = ObservableModel<int>();
    v.value = 7;
    v.stream.listen((d) => expect(7, d));
    expect(7, v.value);
  });
}
