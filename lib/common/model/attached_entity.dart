import 'package:challengeapp/common/dao/abstract_dao.dart';
import 'package:challengeapp/common/model/abstract_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:challengeapp/container/app_context_model.dart';


class AttachedEntity<Entity extends AbstractEntity> extends ValueNotifier<Entity> with Closeable {
  final AbstractDao<Entity> _dao;
  final int id;
  Entity _deleteUndoSave;

  AttachedEntity(this.id, Entity entity, this._dao) : super(entity) {
    assert(this.id != null);
    assert(entity != null);
  }

  Future<Entity> reload() async {
    final needsEvent = value != null;
    value = await _dao.getById(id);
    if (needsEvent) notifyListeners();
    return value;
  }

  Future<Entity> update() async {
    assert(value != null);

    await _dao.update(value);
    notifyListeners();
    return value;
  }

  Future<void> delete() async {
    _deleteUndoSave = value;
    await _dao.delete(this.id);
    value = null;
    return value;
  }

  Future<Entity> undoDelete() async {
    assert(_deleteUndoSave != null);
    if (_deleteUndoSave != null) {
      value = await _dao.insert(_deleteUndoSave);
      _deleteUndoSave = null;
    }
    return value;
  }

  Future<void> close() {
    this.dispose();
    return SynchronousFuture(null);
  }
}