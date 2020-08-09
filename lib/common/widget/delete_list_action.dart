import 'package:challengeapp/common/model/abstract_entity.dart';
import 'package:challengeapp/common/model/attached_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DeleteListAction<Entity extends AbstractEntity> extends StatelessWidget {
  final AttachedEntity<Entity> entity;
  final String deleteInfo;
  final ValueChanged<Entity> deleteCallback;
  final ValueChanged<Entity> undoDeleteCallback;

  const DeleteListAction(this.entity, this.deleteInfo, {Key key, this.deleteCallback, this.undoDeleteCallback})
      : assert(entity != null), super(key: key);

  void _doDelete(BuildContext context) async {
    final e = await entity.delete();
    if (deleteCallback != null) deleteCallback(e);

    Scaffold.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(children: <Widget>[
            Icon(Icons.done),
            const SizedBox(width: 8),
            Text(deleteInfo)
          ],
        ),
        action: SnackBarAction(label: 'Undo',
          textColor: Theme.of(context).accentColor,
          onPressed: () async {
            final e = await entity.undoDelete();
            if (undoDeleteCallback != null) undoDeleteCallback(e);
          }
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconSlideAction(
      caption: 'Delete',
      color: Theme.of(context).errorColor,
      icon: Icons.delete,
      onTap: () => _doDelete(context)
    );
  }
}
