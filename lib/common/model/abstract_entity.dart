abstract class AbstractEntity {
  int id;

  @override
  bool operator == (other) {
    if (id == null) {
      return super == other;
    } else {
      return id == other.id && this.runtimeType == other.runtimeType;
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