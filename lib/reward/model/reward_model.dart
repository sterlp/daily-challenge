import 'package:challengeapp/util/dao/abstract_dao.dart';

class Reward extends AbstractEntity {
  static const NAME_LENGTH = 50;

  String name;
  int cost;

  @override
  String toString() {
    return 'Reward[id=$id, name=$name, cost=$cost]';
  }
}