import 'dart:async';
import 'dart:developer';

import 'package:challengeapp/challengelist/dao/challenge_dao.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/common/model/attached_entity.dart';
import 'package:challengeapp/credit/service/credit_service.dart';
import 'package:challengeapp/log/logger.dart';
import 'package:challengeapp/util/date.dart';

///
/// https://www.sqlite.org/datatype3.html
///
class ChallengeService {
  static final Logger _log = LoggerFactory.get<ChallengeService>();

  final ChallengeDao _challengeDao;
  final CreditService _creditService;

  ChallengeService(this._challengeDao, this._creditService);

  AttachedEntity<Challenge> attach(Challenge challenge) {
    return AttachedEntity<Challenge>(
      challenge.id, challenge, _challengeDao.reload,
      this.save, this.delete, this.insert
    );
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

  Future<Challenge> delete(Challenge c) async {
    var deleted = await _challengeDao.delete(c.id);
    log('Deleted ${c.name}');
    if (deleted > 0 && c.status != ChallengeStatus.open) _creditService.calcTotal();
    return c;
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
    final now = DateTimeUtil.clearTime(DateTime.now());
    final overDue = values.where((c) => c.status == ChallengeStatus.open && c.latestAt.isBefore(now));
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
    final changed = <Challenge>[];
    for(Challenge challenge in values) {
      if (challenge.status == ChallengeStatus.done) {
        challenge.status = ChallengeStatus.open;
        challenge.doneAt = null;
        changed.add(await _challengeDao.save(challenge));
      }
    }
    return _creditService.calcTotal();
  }

  Future<List<Challenge>> loadAndFailOverDue() async {
    final result = await _challengeDao.loadOverDue();
    if (result.isNotEmpty) {
      final failedCount = await failOverDue(result);
      if (failedCount > 0) {
        return _challengeDao.loadOverDue();
      }
    }
    return result;
  }
  Future<List<Challenge>> loadByDate(DateTime dateTime, bool includeOverdue) async {
    List<Challenge> result;

    if (includeOverdue) {
      result = await loadAndFailOverDue();
    } else {
      result = [];
    }

    final openByDate = _challengeDao.loadOpenByDueAt(dateTime);
    final done = _challengeDao.loadDoneByDoneAt(dateTime);

    result.addAll(await openByDate);
    result.addAll(await done);

    return result;
  }

  Future<void> deleteAll() async {
    await _challengeDao.deleteAll();
    _creditService.calcTotal();
  }

  Future<Challenge> insert(Challenge challenge) async {
    final result = await _challengeDao.insert(challenge);
    if (result.status != ChallengeStatus.open) {
      _creditService.calcTotal();
    }
    return result;
  }

  Future<Iterable<String>> completeChallengesName(String pattern) {
    return _challengeDao.loadNamesByPattern(pattern, limit: 5);
  }

  Future<int> countFinished() {
    return _challengeDao.countFinished();
  }
}