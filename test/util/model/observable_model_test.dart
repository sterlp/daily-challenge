import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/util/model/observable_model.dart';

import '../../test_helper.dart';

void main() {
  ObservableModel subject;

  setUp(() {
    if (subject != null) subject.close();
    subject = ObservableModel<int>();
  });

  test('ObservableModel setter test', () {
    subject.value = 7;
    subject.stream.listen((d) => expect(7, d));
    expect(7, subject.value);
  });


  testWidgets('ObservableModel test StreamBuilder update', (WidgetTester tester) async {
    int value;
    await pumpTestApp(tester,
      StreamBuilder(
        stream: subject.stream,
        initialData: subject.value,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            value = snapshot.data;
          }
          return Container(child: Text('${snapshot.data}'));
        },
      )
    );
    subject.value = 7;
    await tester.pumpAndSettle();
    expect(value, 7);
  });

  testWidgets('ObservableModel test StreamBuilder init', (WidgetTester tester) async {
    int value;
    subject.value = 7;
    await pumpTestApp(tester,
        StreamBuilder(
          stream: subject.stream,
          initialData: subject.value,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              value = snapshot.data;
            }
            return Container(child: Text('${snapshot.data}'));
          },
        )
    );

    expect(value, 7);


    subject.value = 99;
    await tester.pumpAndSettle();
    expect(value, 99);
  });
}
