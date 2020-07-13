import 'dart:async';
import 'package:flutterapp/challengelist/dao/challenge_dao.dart';
import 'package:flutterapp/challengelist/models/challenge_model.dart';
import 'package:flutterapp/log/logger.dart';
import 'dart:developer';

import 'package:flutterapp/util/date.dart';
import 'package:flutterapp/util/model/observable_model.dart';

///
/// https://www.sqlite.org/datatype3.html
///
class ChallengeService {
  static final Logger _log = LoggerFactory.get<ChallengeService>();

  final ChallengeDao _challengeDao;
  final _totalPoints = ObservableModel<int>();

  get totalPoints {return _totalPoints.value; }
  Stream<int> get totalPointsStream {return _totalPoints.stream; }

  ChallengeService(this._challengeDao);

  Future<int> getTotal() async {
    if (_totalPoints.value == null) {
      return calcTotal();
    }
    return _totalPoints.value;
  }

  Future<int> calcTotal() async {
    var done = await _challengeDao.sumByStatus(ChallengeStatus.done);
    var failed = await  _challengeDao.sumByStatus(ChallengeStatus.failed);
    var newTotal = done - failed;
    _totalPoints.value = newTotal;
    return newTotal;
  }

  Future<Challenge> getById(int id) async {
    return _challengeDao.getById(id);
  }

  Future<List<Challenge>> saveAll(List<Challenge> challenges) async {
    var results = await _challengeDao.saveAll(challenges);
    return results;
  }

  Future<Challenge> save(Challenge c) async {
    var result = await _challengeDao.save(c);
    return result;
  }

  Future<int> delete(Challenge c) async {
    var deleted = await _challengeDao.delete(c.id);
    log('Deleted ${c.name}');
    if (deleted > 0) return calcTotal();
    else return _totalPoints.value;
  }
  
  Future<List<Challenge>> load() async {
    return _challengeDao.loadAll(orderBy: 'dueAt ASC, createdAt DESC');
  }

  /// Checks the given Challenges for any which are overdue, if found they will be failed.
  Future<int> failOverDue(List<Challenge> values) async {
    var now = DateTimeUtil.clearTime(DateTime.now());
    var overDue = values.where((c) => c.status == ChallengeStatus.open && DateTimeUtil.clearTime(c.latestAt).isBefore(now));
    if (overDue.length > 0) return _fail(overDue.toList());
    else return getTotal();
  }

  Future<int> _fail(List<Challenge> values) async {
    int total = await getTotal();
    int failed = await _challengeDao.fail(values);
    var result = total - failed;
    _totalPoints.value = result;
    _log.info('Failed ${values.length} challenges with $failed points.');
    return result;
  }

  Future<int> complete(List<Challenge> values) async {
    List<Challenge> changed = List();
    for(Challenge challenge in values) {
      if (challenge.status != ChallengeStatus.done) {
        challenge.status = ChallengeStatus.done;
        challenge.doneAt = DateTime.now();
        changed.add(await _challengeDao.save(challenge));
      }
    }
    return calcTotal();
  }
  Future<int> incomplete(List<Challenge> values) async {
    List<Challenge> changed = List();
    for(Challenge challenge in values) {
      if (challenge.status == ChallengeStatus.done) {
        challenge.status = ChallengeStatus.open;
        challenge.doneAt = null;
        changed.add(await _challengeDao.save(challenge));
      }
    }
    return calcTotal();
  }

  Future<List<Challenge>> loadOverDue() async {
    return _challengeDao.loadOverDue();
  }
  Future<List<Challenge>> loadByDate(DateTime dateTime) async {
    return _challengeDao.loadByDate(dateTime);
  }

  Future<void> deleteAll() {
    return _challengeDao.deleteAll();
  }
}