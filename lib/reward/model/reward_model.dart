import 'package:challengeapp/common/model/abstract_entity.dart';

class Reward extends AbstractEntity {
  static const NAME_LENGTH = 50;

  String name = '';
  int cost = 0;

  @override
  String toString() {
    return 'Reward[id=$id, name=$name, cost=$cost]';
  }
}
