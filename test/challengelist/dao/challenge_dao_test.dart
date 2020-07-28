import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/challengelist/dao/challenge_dao.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/container/app_context.dart';
import 'package:flutterapp/util/random_util.dart';
import '../../test_helper.dart';

void main() {
  AppContext context;
  ChallengeDao subject;

  setUpAll(() {
    context = testContainer();
    subject = context.get<ChallengeDao>();
  });
  setUp(() async {
    await subject.deleteAll();
  });
  tearDown(() async => await subject.deleteAll());
  tearDownAll(() async {
    if (context != null) await context.close();
    context = null;
  });

  test('Challenge toMap', () {
    final Challenge c = Challenge.of('test');

    c.dueAt = null;
    var map = subject.toMap(c);
    // Verify that our counter starts at 0.
    expect(map['id'], null);
    expect(map['name'], 'test');
    expect(map['status'], 'open');
    expect(map['createdAt'] <= DateTime.now().millisecondsSinceEpoch, true);
    expect(map['dueAt'], null);
  });

  test('Challenge fromMap', () {
    var d = DateTime.now().millisecondsSinceEpoch;

    final Challenge c = subject.fromMap({
      'id': 5,
      'name': 'Bar',
      'status': 'done',
      'createdAt': d,
      'doneAt': d + 1,
      'dueAt': d + 2,
      'latestAt': null
    });
    expect(c.status, ChallengeStatus.done);
    expect(c.name, 'Bar');
    expect(c.createdAt.millisecondsSinceEpoch, d);
    expect(c.doneAt.millisecondsSinceEpoch, d + 1);
    expect(c.latestAt, null);
  });

  test('Query empty DB', () async {
    List<Challenge> results = await subject.loadAll();
    expect(results.length, 0);

    await subject.insert(Challenge.of('Test 1'));
    results = await subject.loadAll();
    expect(results.length, 1);
  });

  test('Save and load test', () async {
    var c = Challenge.of('Test 1');
    c.status = ChallengeStatus.done;

    c = await subject.save(c);
    expect(c.id != null && c.id > -1, true, reason: "Id wasn't set on $c");

    var newC = await subject.getById(c.id);
    expect(newC == null, false, reason: 'Failed to find element by id ${c.id}');
    expect(c.name, newC.name);
    expect(c.status, newC.status);
    expect(c.dueAt.millisecondsSinceEpoch, newC.dueAt.millisecondsSinceEpoch);
  });

  test('Query loadByDate', () async {
    var now = DateTime.now();
    await subject.save(Challenge.of('Test 1'));
    await subject.save(Challenge.of('Test 2'));
    await subject.save(Challenge.of('Test 3', now.add(Duration(days: -1))));
    await subject.save(Challenge.of('Test 4', now.add(Duration(days: -2))));
    await subject.save(Challenge.of('Test 5', now.add(Duration(days: 1))));

    var results = await subject.loadByDate(now);
    expect(results.length, 2);
    expect(results[0].name, 'Test 1');
    expect(results[1].name, 'Test 2');

    results = await subject.loadByDate(now.add(Duration(days: 1)));
    expect(results.length, 1);
    expect(results[0].name, 'Test 5');

    results = await subject.loadByDate(now.add(Duration(days: -1)));
    expect(results.length, 1);
    expect(results[0].name, 'Test 3');
  });

  test('Query load one by date', () async {
    var now = DateTime(2020, 5, 17);
    await subject.save(Challenge.full('Test 1', now, ChallengeStatus.done));
    var results = await subject.loadByDate(now);
    expect(results.length, 1);
    expect(results[0].name, 'Test 1');
  });

  test('Query loadOverDue and fail them', () async {
    var now = DateTime.now();
    await subject.save(Challenge.of('Test 1', now.add(Duration(minutes: 10))));
    await subject.save(Challenge.of('Test 2', now.add(Duration(days: -1))));
    await subject.save(Challenge.of('Test 3', now.add(Duration(days: -33))));
    await subject.save(Challenge.full('Test 4', now.add(Duration(days: -2)), ChallengeStatus.done));

    var results = await subject.loadOverDue();
    expect(results.length, 2);
    expect(results[0].name, 'Test 3');
    expect(results[1].name, 'Test 2');

    results[0].reward = 1;
    results[1].reward = 2;

    expect(await subject.fail(results), 3);
    results = await subject.loadOverDue();
    expect(results.length, 0);
  });

  test('Delete test', () async {
    Challenge c = await subject.save(Challenge.of('Foo'));
    expect((await subject.loadAll()).length, 1);

    await subject.delete(c.id);
    expect((await subject.loadAll()).length, 0);
  });

  test('Delete challenge count test', () async {
    Challenge c = Challenge.of('Foo');
    c.reward = 99;
    // delete no ID and not created
    int count = await subject.delete(c.id);
    expect(count, 0);

    // delete  task
    await subject.save(c);
    count = await subject.delete(c.id);
    expect(count, 1);

    // delete a deleted task
    count = await subject.delete(c.id);
    expect(count, 0);
  });

  test('Save again after delete', () async {
    await subject.deleteAll();
    final Challenge c = await subject.save(Challenge.of('Foo'));
    expect(await subject.countAll(), 1);

    subject.delete(c.id);
    expect(await subject.countAll(), 0);

    subject.insert(c);
    expect(await subject.countAll(), 1);
  });

  test('Save long name', () async {
    await subject.deleteAll();
    final _name = RandomUtil.randomString(100);
    Challenge c = await subject.save(Challenge.of(_name));
    expect(await subject.countAll(), 1);

    c = await subject.getById(c.id);
    expect(c.name, _name);
  });

  test('Test loadNamesByPattern', () async {
    await subject.save(Challenge.of('Foo')..status = ChallengeStatus.done);
    await subject.save(Challenge.of('Faa')..status = ChallengeStatus.done);
    await subject.save(Challenge.of('Boo')..status = ChallengeStatus.done);
    await subject.save(Challenge.of('Not done'));

    var result = await subject.loadNamesByPattern('k');
    expect(result.toList().length, 0);

    result = await subject.loadNamesByPattern('F');
    expect(result.toList().length, 2);

    result = await subject.loadNamesByPattern('Foo');
    expect(result.toList().length, 1);

    result = await subject.loadNamesByPattern('Bo');
    expect(result.toList().length, 1);

    result = await subject.loadNamesByPattern('Not');
    expect(result.toList().length, 0);
  });
}


