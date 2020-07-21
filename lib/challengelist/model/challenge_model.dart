import 'package:flutterapp/util/dao/abstract_dao.dart';
import 'package:flutterapp/util/date.dart';
import 'package:intl/intl.dart';

enum ChallengeStatus {
  open,
  done,
  failed
}

class Challenge extends AbstractEntity {
  static const NAME_LENGTH = 100;

  static final DateFormat doneFormat = DateFormat("EEEEE, LLLL dd");
  static final DateFormat dueFormat = DateFormat("EEEEE, LLLL dd");
  static final Duration defaultChallengeWaitTime = Duration(days: 7);

  String name;
  int reward = 0;
  ChallengeStatus status = ChallengeStatus.open;
  DateTime createdAt = DateTime.now();
  DateTime doneAt;
  DateTime dueAt = DateTime.now();
  DateTime latestAt = DateTime.now().add(defaultChallengeWaitTime);

  Challenge();

  Challenge.withName(String v) {
    name = v;
  }
  Challenge.withNameAndDate(this.name, this.dueAt) {
     this.latestAt = this.dueAt.add(defaultChallengeWaitTime);
  }
  Challenge.withNameDateAndStatus(this.name, this.dueAt, this.status) {
    this.latestAt = this.dueAt.add(defaultChallengeWaitTime);
  }

  bool get isOverdue => DateTimeUtil.clearTime(dueAt).isBefore(DateTimeUtil.clearTime(DateTime.now()));
  bool get isDone => status == ChallengeStatus.done;
  bool get isFailed => status == ChallengeStatus.failed;

  @override
  String toString() {
    return 'Challenge[id=$id, name=$name, reward=$reward, status=$status]';
  }
}