import 'dart:async';
import 'package:flutterapp/challengelist/dao/challenge_dao.dart';
import 'package:flutterapp/challengelist/model/challenge_model.dart';
import 'package:flutterapp/credit/service/credit_service.dart';
import 'package:flutterapp/log/logger.dart';
import 'dart:developer';

import 'package:flutterapp/util/date.dart';

///
/// https://www.sqlite.org/datatype3.html
///
class ChallengeService {
  static final Logger _log = LoggerFactory.get<ChallengeService>();

  final ChallengeDao _challengeDao;
  final CreditService _creditService;

  ChallengeService(this._challengeDao, this._creditService);

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
    if (deleted > 0) return _creditService.calcTotal();
    else return _creditService.credit;
  }
  
  Future<List<Challenge>> loadAll() {
    return _challengeDao.loadAll(orderBy: 'dueAt ASC, createdAt DESC');
  }

  Future<List<Challenge>> listCompleted() {
    return _challengeDao.loadAll(
        where: 'status <> "open"',
        orderBy: 'doneAt DESC');
  }

  /// Checks the given Challenges for any which are overdue, if found they will be failed.
  Future<int> failOverDue(List<Challenge> values) async {
    var now = DateTimeUtil.clearTime(DateTime.now());
    var overDue = values.where((c) => c.status == ChallengeStatus.open && DateTimeUtil.clearTime(c.latestAt).isBefore(now));
    if (overDue.length > 0) return _fail(overDue.toList());
    else return _creditService.credit;
  }

  Future<int> _fail(List<Challenge> values) async {
    final failed = await _challengeDao.fail(values);
    _log.info('Failed ${values.length} challenges with $failed points.');
    return _creditService.calcTotal();
  }

  Future<int> complete(List<Challenge> values) async {
    final now = DateTime.now();
    for(Challenge challenge in values) {
      if (challenge.status != ChallengeStatus.done) {
        challenge.status = ChallengeStatus.done;
        challenge.doneAt = now;
        await _challengeDao.save(challenge);
      }
    }
    return _creditService.calcTotal();
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
    return _creditService.calcTotal();
  }

  Future<List<Challenge>> loadOverDue() async {
    return _challengeDao.loadOverDue();
  }
  Future<List<Challenge>> loadByDate(DateTime dateTime) async {
    return _challengeDao.loadByDate(dateTime);
  }

  Future<void> deleteAll() async {
    await _challengeDao.deleteAll();
    _creditService.calcTotal();
  }

  Future<Challenge> insert(Challenge challenge) {
    return _challengeDao.insert(challenge);
  }

  Future<Iterable<String>> completeChallengesName(String pattern) {
    return _challengeDao.loadNamesByPattern(pattern, limit: 5);
  }

  Future<int> countFinished() {
    return _challengeDao.countFinished();
  }
}