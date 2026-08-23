import 'package:challengeapp/common/model/abstract_entity.dart';
import 'package:challengeapp/util/date.dart';

enum ChallengeStatus { open, done, failed }

class Challenge extends AbstractEntity {
  static const NAME_LENGTH = 100;
  static const Duration defaultChallengeWaitTime = Duration(days: 7);

  Challenge();
  Challenge.of(this.name, [DateTime? dueAt, this.reward = 0]) {
    this.dueAt = dueAt ?? DateTime.now();
  }
  Challenge.full(
    this.name, [
    DateTime? dueAt,
    this.status = ChallengeStatus.open,
    this.reward = 0,
    DateTime? doneAt,
  ]) {
    this.doneAt = doneAt;
    this.dueAt = dueAt ?? DateTime.now();
    _latestAt ??= this.dueAt!.add(defaultChallengeWaitTime);
    if (status != ChallengeStatus.open && doneAt == null) {
      this.doneAt = DateTime.now();
    }
  }

  String name = '';
  int reward = 0;
  ChallengeStatus status = ChallengeStatus.open;
  DateTime createdAt = DateTime.now();
  DateTime? doneAt;

  DateTime? _dueAt;
  DateTime? get dueAt => DateTimeUtil.clearTime(_dueAt);
  set dueAt(DateTime? v) =>
      _dueAt = v == null ? null : DateTimeUtil.clearTime(v);

  DateTime? _latestAt;
  DateTime? get latestAt => DateTimeUtil.clearTime(_latestAt);
  set latestAt(DateTime? v) =>
      _latestAt = v == null ? null : DateTimeUtil.clearTime(v);

  Duration latestDiff(DateTime date) {
    final l = latestAt;
    return l == null
        ? const Duration(days: 99)
        : l.difference(DateTimeUtil.clearTime(date)!);
  }

  bool get isOverdue =>
      dueAt != null && dueAt!.isBefore(DateTimeUtil.clearTime(DateTime.now())!);
  bool get isDone => status == ChallengeStatus.done;
  bool get isFailed => status == ChallengeStatus.failed;

  @override
  String toString() {
    return 'Challenge[id=$id, name=$name, reward=$reward, status=$status'
        ', dueAt=$dueAt, latestAt=$latestAt]';
  }
}
