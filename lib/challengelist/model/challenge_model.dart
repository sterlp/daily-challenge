import 'package:challengeapp/util/dao/abstract_dao.dart';
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
  Challenge.of(this.name, [this.dueAt, this.reward = 0]) {
    this.dueAt ??= DateTime.now();
  }
  Challenge.full(this.name, [this.dueAt, this.status = ChallengeStatus.open, this.reward = 0, this.doneAt]) {
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
  DateTime dueAt;
  DateTime latestAt;

  bool get isOverdue => DateTimeUtil.clearTime(dueAt).isBefore(DateTimeUtil.clearTime(DateTime.now()));
  bool get isDone => status == ChallengeStatus.done;
  bool get isFailed => status == ChallengeStatus.failed;

  @override
  String toString() {
    return 'Challenge[id=$id, name=$name, reward=$reward, status=$status]';
  }
}