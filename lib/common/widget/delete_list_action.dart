import 'package:challengeapp/common/model/abstract_entity.dart';
import 'package:challengeapp/common/model/attached_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DeleteListAction<Entity extends AbstractEntity> extends StatelessWidget {
  final AttachedEntity<Entity> entity;
  final String deleteInfo;
  final ValueChanged<Entity>? deleteCallback;
  final ValueChanged<Entity>? undoDeleteCallback;

  const DeleteListAction(
    this.entity,
    this.deleteInfo, {
    super.key,
    this.deleteCallback,
    this.undoDeleteCallback,
  });

  Future<void> _doDelete(BuildContext context) async {
    final e = (await entity.delete())!;
    deleteCallback?.call(e);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: <Widget>[
            const Icon(Icons.done),
            const SizedBox(width: 8),
            Text(deleteInfo),
          ],
        ),
        action: SnackBarAction(
          label: 'Undo',
          // ignore: use_build_context_synchronously
          textColor: Theme.of(context).colorScheme.secondary,
          onPressed: () async {
            final e = (await entity.undoDelete())!;
            // ignore: use_build_context_synchronously
            undoDeleteCallback?.call(e);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlidableAction(
      label: 'Delete',
      backgroundColor: Theme.of(context).colorScheme.error,
      icon: Icons.delete,
      onPressed: _doDelete,
    );
  }
}
