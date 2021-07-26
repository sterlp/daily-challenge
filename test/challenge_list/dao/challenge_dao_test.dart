import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:challengeapp/challengelist/dao/challenge_dao.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/util/random_util.dart';

import '../../test_helper.dart';

void main() {
  AppContainer context;
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
    final map = subject.toMap(c);
    // Verify that our counter starts at 0.
    expect(map['id'], null);
    expect(map['name'], 'test');
    expect(map['status'], 'open');
    expect(map['createdAt'] <= DateTime.now().millisecondsSinceEpoch, true);
    expect(map['dueAt'], null);
  });

  test('Challenge fromMap', () {
    final d = DateTime.now().millisecondsSinceEpoch;

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

  test('Sorting first using latestAt for overdue', () async {
    final now = DateTime.now();
    await subject.save(Challenge.of('In 5 days')
      ..dueAt = now.add(const Duration(days: -6))
      ..latestAt = now.add(const Duration(days: 5)));
    await subject.save(Challenge.of('In 2 days')
      ..dueAt = now.add(const Duration(days: -12))
      ..latestAt = now.add(const Duration(days: 2)));
    await subject.save(Challenge.of('In 1 day')
      ..dueAt = now.add(const Duration(days: -11))
      ..latestAt = now.add(const Duration(days: 1)));
    await subject.save(Challenge.of('In 10 days')
      ..dueAt = now
      ..latestAt = now.add(const Duration(days: 10)));

    final results = await subject.loadOverDue();
    expect(results.length, 3);

    expect(results[0].latestAt, isNotNull);
    expect(results[0].name, 'In 1 day');
    expect(results[1].name, 'In 2 days');
    expect(results[2].name, 'In 5 days');
  });

  test('Failing soon showed first', () async {
    final now = DateTime.now();
    await subject.save(Challenge.of('In 5 days')
      ..latestAt = now.add(const Duration(days: 5)));
    await subject.save(Challenge.of('In 2 days')
      ..latestAt = now.add(const Duration(days: 2)));
    await subject.save(Challenge.of('In 1 day')
      ..latestAt = now.add(const Duration(days: 1)));
    await subject.save(Challenge.of('In 10 days')
      ..latestAt = now.add(const Duration(days: 10)));

    final results = await subject.loadOpenByDueAt(now);
    expect(results.length, 4);

    expect(results[0].latestAt, isNotNull);
    expect(results[0].name, 'In 1 day');
    expect(results[1].name, 'In 2 days');
    expect(results[2].name, 'In 5 days');
    expect(results[3].name, 'In 10 days');
  });

  test('Query loadByDate', () async {
    final now = DateTime.now();
    await subject.save(Challenge.of('Test 1'));
    await Future.delayed(const Duration(milliseconds : 1));
    await subject.save(Challenge.of('Test 2'));
    await subject.save(Challenge.of('Test 3', now.add(const Duration(days: -1))));
    await subject.save(Challenge.of('Test 4', now.add(const Duration(days: -2))));
    await subject.save(Challenge.of('Test 5', now.add(const Duration(days: 1))));

    var results = await subject.loadOpenByDueAt(now);
    expect(results.length, 2);
    expect(results[0].name, 'Test 2');
    expect(results[1].name, 'Test 1');

    results = await subject.loadOpenByDueAt(now.add(const Duration(days: 1)));
    expect(results.length, 1);
    expect(results[0].name, 'Test 5');

    results = await subject.loadOpenByDueAt(now.add(const Duration(days: -1)));
    expect(results.length, 1);
    expect(results[0].name, 'Test 3');
  });

  test('Load done and failed tasks', () async {
    final now = DateTime(2020, 5, 17);
    await subject.save(Challenge.full('Done', now, ChallengeStatus.done)
      ..doneAt = now);
    await subject.save(Challenge.full('Failed', now, ChallengeStatus.failed)
      ..doneAt = now);
    await subject.save(Challenge.of('Open', now.add(const Duration(minutes: 10)))
      ..dueAt = now);

    final results = await subject.loadDoneByDoneAt(now);

    expect(results.length, 2);
    expect(results[0].name, 'Failed');
    expect(results[1].name, 'Done');
  });

  test('Query loadOverDue and fail them', () async {
    final now = DateTime.now();
    await subject.save(Challenge.of('Test 1', now.add(const Duration(minutes: 10))));
    await subject.save(Challenge.of('Test 2', now.add(const Duration(days: -1))));
    await subject.save(Challenge.of('Test 3', now.add(const Duration(days: -33))));
    await subject.save(Challenge.full('Test 4', now.add(const Duration(days: -2)), ChallengeStatus.done));

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
    final c = Challenge.of('Foo');
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

    result = await subject.loadNamesByPattern('Fo');
    expect(result.toList().length, 1);

    result = await subject.loadNamesByPattern('Foo');
    expect(result.toList().length, 0);

    result = await subject.loadNamesByPattern('Bo');
    expect(result.toList().length, 1);

    result = await subject.loadNamesByPattern('Not');
    expect(result.toList().length, 0);
  });
}


