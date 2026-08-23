abstract class AbstractEntity {
  int? id;

  @override
  bool operator ==(Object other) {
    if (id == null) {
      return super == other;
    } else {
      return other is AbstractEntity &&
          id == other.id &&
          runtimeType == other.runtimeType;
    }
  }

  @override
  int get hashCode {
    if (id == null) {
      return super.hashCode;
    } else {
      return id.hashCode;
    }
  }
}
