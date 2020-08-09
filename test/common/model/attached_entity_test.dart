import 'package:challengeapp/common/dao/abstract_dao.dart';
import 'package:challengeapp/common/model/abstract_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TestEntity extends AbstractEntity {
  String name;
}
class TestDao extends AbstractDao<TestEntity> {
  TestDao(Future<Database> db) : super(db, "TEST_ENTITY");
  @override
  TestEntity fromMap(Map<String, dynamic> values) {
    final result = TestEntity();
    result.id = values['id'];
    result.name = values['name'];
    return result;
  }
  @override
  Map<String, dynamic> toMap(TestEntity value) {
    return {
      'id': value.id,
      'name': value.name,
    };
  }
}

void main() {
  Database db;
  TestDao subject;

  setUpAll(() async {
    sqfliteFfiInit();
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''CREATE TABLE IF NOT EXISTS TEST_ENTITY (
          id integer PRIMARY KEY AUTOINCREMENT,
          name text NOT NULL
        );
      ''');
    subject = TestDao(SynchronousFuture(db));
  });
  setUp(() async {
    subject.deleteAll();
  });

  test('Test CRUD AttachedEntity', () async {
    var e = await subject.save(TestEntity()..name = "Test 1");
    await subject.save(TestEntity()..name = "Test 2");

    var attached = subject.attach(e);

    bool eventFired = false;
    attached.addListener(() => eventFired = true);

    attached.value.name = "Test 11";
    expect(eventFired, false);

    await attached.update();
    expect(eventFired, true);

    expect((await subject.getById(e.id)).name, "Test 11");

    eventFired = false;
    await attached.delete();
    expect(eventFired, true);
    expect(attached.value, isNull);
    expect(await subject.countAll(), 1);

    eventFired = false;
    await attached.undoDelete();
    expect(attached.value, isNotNull);
    expect(await subject.countAll(), 2);

    attached = await subject.getAttached(e.id);
    expect(attached.value, isNotNull);
    expect(attached.value.name, "Test 11");
  });
}