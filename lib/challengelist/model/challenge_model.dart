import 'package:challengeapp/common/model/abstract_entity.dart';
import 'package:challengeapp/util/date.dart';

enum ChallengeStatus {
  open,
  done,
  failed
}

class Challenge extends AbstractEntity {
  static const NAME_LENGTH = 100;
  static final Duration defaultChallengeWaitTime = Duration(days: 7);

  Challenge();
  Challenge.of(this.name, [this._dueAt, this.reward = 0]) {
    this.dueAt ??= DateTime.now();
  }
  Challenge.full(this.name, [this._dueAt, this.status = ChallengeStatus.open, this.reward = 0, this.doneAt]) {
    this.dueAt ??= DateTime.now();
    this.latestAt ??= this.dueAt.add(defaultChallengeWaitTime);
    if (this.status != ChallengeStatus.open && this.dueAt == null) {
      doneAt = DateTime.now();
    }
  }

  String name;
  int reward;
  ChallengeStatus status = ChallengeStatus.open;
  DateTime createdAt = DateTime.now();
  DateTime doneAt;

  DateTime _dueAt;
  DateTime get dueAt => DateTimeUtil.clearTime(_dueAt);
  set dueAt(DateTime v) => _dueAt = DateTimeUtil.clearTime(v);

  DateTime _latestAt;
  DateTime get latestAt => DateTimeUtil.clearTime(_latestAt);
  set latestAt(DateTime v) => _latestAt = DateTimeUtil.clearTime(v);

  Duration latestDiff(DateTime date) => latestAt == null ? const Duration(days: 0) : latestAt.difference(DateTimeUtil.clearTime(date));

  bool get isOverdue => dueAt.isBefore(DateTimeUtil.clearTime(DateTime.now()));
  bool get isDone => status == ChallengeStatus.done;
  bool get isFailed => status == ChallengeStatus.failed;

  @override
  String toString() {
    return 'Challenge[id=$id, name=$name, reward=$reward, status=$status]';
  }
}