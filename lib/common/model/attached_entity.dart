import 'package:challengeapp/common/model/abstract_entity.dart';
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/foundation.dart';

typedef AttachedEntityAction<T> = Future<T> Function(T value);

class AttachedEntity<Entity extends AbstractEntity> extends ValueNotifier<Entity> with Closeable {
  final int id;
  final AttachedEntityAction<Entity> doReloadCallback;
  final AttachedEntityAction<Entity> doSaveCallback;
  final AttachedEntityAction<Entity> doDeleteCallback;
  final AttachedEntityAction<Entity> doUnDeleteCallback;

  Entity _deleteUndoSave;
  bool _closed = false;
  get isClosed => _closed;

  AttachedEntity(this.id, Entity entity, this.doReloadCallback, this.doSaveCallback, this.doDeleteCallback, this.doUnDeleteCallback) : super(entity) {
    assert(this.id != null);
    assert(entity != null);
  }

  Future<Entity> reload() async {
    final needsEvent = value != null;
    value = await doReloadCallback(value);
    if (needsEvent) notifyListeners();
    return value;
  }

  Future<Entity> update() async {
    assert(value != null);

    value = await doSaveCallback(value);
    notifyListeners();
    return value;
  }

  Future<Entity> delete() async {
    _deleteUndoSave = value;
    await doDeleteCallback(value);
    value = null;
    return _deleteUndoSave;
  }

  Future<Entity> undoDelete() async {
    assert(_deleteUndoSave != null);
    final v = await doUnDeleteCallback(_deleteUndoSave);
    _deleteUndoSave = null;
    if (!_closed) value = v;
    return v;
  }

  dispose() {
    _closed = true;
    super.dispose();
  }
  Future<void> close() {
    this.dispose();
    return SynchronousFuture(null);
  }
}