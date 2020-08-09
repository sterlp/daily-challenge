import 'package:challengeapp/common/model/abstract_entity.dart';
import 'package:challengeapp/common/model/attached_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

abstract class AbstractDao<T extends AbstractEntity> {
  final Future<Database> _db;
  final String tableName;

  AbstractDao(this._db, this.tableName);

  Future<DatabaseExecutor> get dbExecutor => _db;

  AttachedEntity<T> attach(T entity) {
    return AttachedEntity<T>(entity.id, entity,
        reload, save, deleteEntity, insert
    );
  }

  Future<AttachedEntity<T>> getAttached(int id) async {
    return AttachedEntity<T>(id, await getById(id),
        reload, save, deleteEntity, insert);
  }

  Future<T> reload(T e) async {
    return getById(e.id);
  }

  Future<T> getById(int id) async {
    assert(id != null);

    final Database db = await dbExecutor;
    final List<Map<String, dynamic>> results = await db.query(
        tableName,
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

  Future<int> deleteAll() async {
    final Database db = await dbExecutor;
    return db.delete(tableName);
  }

  Future<int> delete(int id) async {
    if (id == null) return 0;

    final Database db = await dbExecutor;
    return db.delete(tableName, where: "id = ?", whereArgs: [id]);
  }

  Future<T> deleteEntity(T e) async {
    if (e == null || e.id == null) return SynchronousFuture(e);

    await delete(e.id);
    return e;
  }

  Future<List<T>> saveAll(List<T> entities) async {
    assert(entities != null);

    for(T e in entities) await save(e);

    return entities;
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
    await db.update(tableName, toMap(entity), where: "id = ?", whereArgs: [entity.id]);
    // if (count == 0) _log.warn('Record not found anymore to update $entity');
    return entity;
  }

  Future<int> countAll() async {
    final Database db = await dbExecutor;

    final r = await db.rawQuery("SELECT COUNT(*) as result FROM $tableName");
    return Sqflite.firstIntValue(r) ?? 0;
  }

  T fromMap(Map<String, dynamic> values);
  Map<String, dynamic> toMap(T value);
}