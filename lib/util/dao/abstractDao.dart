import 'package:sqflite/sqflite.dart';

abstract class AbstractEntity {
  int id;

  @override
  bool operator == (other) {
    if (id == null) {
      return super == other;
    } else {
      return id == other.id;
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

abstract class AbstractDao<T extends AbstractEntity> {
  final Future<Database> _db;
  final String tableName;

  AbstractDao(this._db, this.tableName);

  Future<DatabaseExecutor> get dbExecutor => _db;

  Future<T> getById(int id) async {
    final Database db = await dbExecutor;
    final List<Map<String, dynamic>> results = await db.query(
        'CHALLENGE',
        where: "id = ?",
        whereArgs: [id]);
    assert(results.length <= 1, 'Get by ID should return only one element but returned ${results.length} elements.');
    return results.length == 0 ? null : fromMap(results[0]);
  }

  Future<List<T>> loadAll({bool distinct,
      String where,
      List<dynamic> whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) async {

    final Database db = await dbExecutor;
    final List<Map<String, dynamic>> results = await db.query(tableName,
        where: where, whereArgs: whereArgs, groupBy: groupBy, having: having,
        orderBy: orderBy, limit: limit, offset: offset);

    return results.map((e) => fromMap(e)).toList();
  }

  Future<int> delete(int id) async {
    if (id == null) return 0;

    final Database db = await dbExecutor;
    return db.delete(tableName, where: "id = ?", whereArgs: [id]);
  }
  ///
  /// Checks if the id is set of the entity and either calls insert or update
  ///
  Future<T> save(T entity) async {
    assert(entity != null);

    if (entity.id == null) {
      entity = await insert(entity);
    } else {
      entity = await update(entity);
    }
    return entity;
  }
  Future<T> insert(T entity) async {
    assert(entity != null);

    final Database db = await dbExecutor;
    entity.id = await db.insert(tableName, toMap(entity));
    return entity;
  }
  Future<T> update(T entity) async {
    assert(entity != null);
    assert(entity.id != null);

    final Database db = await dbExecutor;
    db.update(tableName, toMap(entity), where: "id = ?", whereArgs: [entity.id]);
    return entity;
  }

  T fromMap(Map<String, dynamic> values);
  Map<String, dynamic> toMap(T value);
}