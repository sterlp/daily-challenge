import 'package:challengeapp/challengelist/i18n/challengelist_localization.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/challengelist/page/challenge_page.dart';
import 'package:challengeapp/challengelist/service/challenge_service.dart';
import 'package:challengeapp/challengelist/widget/reward_widget.dart';
import 'package:challengeapp/common/model/attached_entity.dart';
import 'package:challengeapp/common/widget/delete_list_action.dart';
import 'package:challengeapp/i18n/challenge_localization_delegate.dart';
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ChallengeWidget extends StatefulWidget {
  final AppContainer appContainer;
  final Challenge challenge;
  final ValueChanged<Challenge> deleteCallback;
  final ValueChanged<Challenge> undoDeleteCallback;

  const ChallengeWidget(this.appContainer, this.challenge,
      {Key key, this.deleteCallback, this.undoDeleteCallback}) : super(key: key);

  @override
  _ChallengeWidgetState createState() => _ChallengeWidgetState();
}

class _ChallengeWidgetState extends State<ChallengeWidget> {
  static const _notOpenTextStyle = TextStyle(decoration: TextDecoration.lineThrough);
  static const _edge = EdgeInsets.all(4.0);

  AttachedEntity<Challenge> _attached;
  TextStyle _overDueStyle;

  ChallengeListLocalizations _i18n;
  ChallengeLocalizations _commonI18n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _i18n = Localizations.of<ChallengeListLocalizations>(context, ChallengeListLocalizations);
    _commonI18n = Localizations.of<ChallengeLocalizations>(context, ChallengeLocalizations);
    _overDueStyle = TextStyle(color: Theme.of(context).errorColor);
    if (_attached != null) {
      _attached.close();
      _attached = null;
    }
  }
  @override
  void dispose() {
    if (_attached != null) {
      _attached.close();
      _attached = null;
    }
    super.dispose();
  }

  Future<void> _onEditChallenge() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => ChallengePage(challenge: widget.challenge),
          fullscreenDialog: true
        )
    );
    if (result != null) setState(() {});
  }

  Future<void> _onChallengeChecked(bool value, BuildContext context) async {
    if (widget.challenge.isFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Challenge ${widget.challenge.name} already failed.')));
    } else {
      final _challengeService = widget.appContainer.get<ChallengeService>();
      if (value) {
        await _challengeService.complete([widget.challenge]);
      } else {
        await _challengeService.incomplete([widget.challenge]);
      }
      // update view
      setState(() { });
    }
    return;
  }

  Widget _dueText() {
    final challenge = widget.challenge;
    final done = challenge.isDone;
    final failed = challenge.isFailed;

    Widget result;
    final daysLeft = challenge.latestDiff(DateTime.now());

    if (done) {
      result = Text(_i18n.doneAt(_commonI18n.formatDate(challenge.doneAt)));
    } else if (failed) {
      result = Text(_i18n.failedSince(_commonI18n.formatDate(challenge.latestAt)), style: _overDueStyle);
    } else if (daysLeft.inDays == 0) {
      result = Text(_i18n.challengeWillFail(challenge.latestDiff(DateTime.now())), style: _overDueStyle);
    } else if (challenge.isOverdue) {
      if (challenge.latestAt == null) {
        return Text('Was due ' + _commonI18n.formatDate(challenge.dueAt), style: _overDueStyle);
      } else {
        result = Text(_i18n.challengeWillFail(challenge.latestDiff(DateTime.now())), style: _overDueStyle);
      }
    } else {
      return Text(_i18n.dueUntil(_commonI18n.formatDate(challenge.dueAt)));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final _challengeService = widget.appContainer.get<ChallengeService>();

    final challenge = widget.challenge;
    final done = challenge.isDone;
    final failed = challenge.isFailed;
    final theme = Theme.of(context);
    _attached ??= _challengeService.attach(challenge);
    assert(_attached != null);

    final actions = <Widget>[];
    if (widget.deleteCallback != null) {
      actions.add(
        Padding(
          padding: _edge,
          child: DeleteListAction(
            _attached, "Challenge deleted.",
            deleteCallback: widget.deleteCallback,
            undoDeleteCallback: widget.undoDeleteCallback,
          ),
        )
      );
    }
    // allow edit only for non completed challenges
    if (challenge.status == ChallengeStatus.open) {
      actions.add(
        Padding(
          padding: _edge,
          child: IconSlideAction(
            caption: 'Edit',
            color: theme.primaryColor,
            icon: Icons.edit,
            onTap: _onEditChallenge
          ),
        )
      );
    }

    return Slidable(
      actionPane: const SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Card(
        child: ListTile(
          leading: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            // transitionBuilder: (child, animation) => ScaleTransition(child: child, scale: animation),
            child: RewardWidget(
              reward: widget.challenge.reward,
              status: widget.challenge.status,
              key: ValueKey('${widget.challenge.id}_${widget.challenge.status}'),
            )
          ),
          title: Text(challenge.name, style: done || failed ? _notOpenTextStyle : null),
          subtitle: _dueText(),
          isThreeLine: true,
          onLongPress: challenge.status == ChallengeStatus.open ? _onEditChallenge : null,
          trailing: _buildCheckbox(),
        ),
      ),
      secondaryActions: actions
    );
  }

  Widget _buildCheckbox() {
    if (widget.challenge.status == ChallengeStatus.failed) {
      return null;
    } else {
      return  SizedBox(
        height: 64,
        child: Checkbox(
          value: widget.challenge.isDone,
          onChanged: (v) => _onChallengeChecked(v, context),
        ),
      );
    }
  }
}
