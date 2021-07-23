import 'package:challengeapp/challengelist/i18n/challengelist_localization.dart';
import 'package:challengeapp/challengelist/model/challenge_model.dart';
import 'package:challengeapp/challengelist/page/challenge_page.dart';
import 'package:challengeapp/challengelist/service/challenge_service.dart';
import 'package:challengeapp/challengelist/widget/reward_widget.dart';
import 'package:challengeapp/common/model/attached_entity.dart';
import 'package:challengeapp/common/widget/delete_list_action.dart';
import 'package:challengeapp/home/state/app_state_widget.dart';
import 'package:challengeapp/i18n/challenge_localization_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ChallengeWidget extends StatefulWidget {
  final Challenge challenge;
  final ValueChanged<Challenge> deleteCallback;
  final ValueChanged<Challenge> undoDeleteCallback;

  ChallengeWidget(this.challenge,
      {Key key, this.deleteCallback, this.undoDeleteCallback}) : super(key: key);

  @override
  _ChallengeWidgetState createState() => _ChallengeWidgetState();
}

class _ChallengeWidgetState extends State<ChallengeWidget> {
  static const _notOpenTextStyle = TextStyle(decoration: TextDecoration.lineThrough);
  static const _edge = EdgeInsets.all(4.0);

  ChallengeService _challengeService;
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
    _challengeService = AppStateWidget.of(context).get<ChallengeService>();
    if (_attached != null) {
      _attached.close();
      _attached = null;
    }
  }
  void dispose() {
    if (_attached != null) {
      _attached.close();
      _attached = null;
    }
    super.dispose();
  }

  _onEditChallenge() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => ChallengePage(challenge: widget.challenge),
          fullscreenDialog: true
        )
    );
    if (result != null) setState(() {});
  }

  _onChallengeChecked(bool value, BuildContext context) async {
    if (widget.challenge.isFailed) {
      Scaffold.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Challenge ${widget.challenge.name} already failed.')));
    } else {
      final _challengeService = AppStateWidget.of(context).get<ChallengeService>();
      if (value) {
        await _challengeService.complete([widget.challenge]);
      } else {
        await _challengeService.incomplete([widget.challenge]);
      }
      // update view
      setState(() { });
    }
  }

  Widget _dueText() {
    final challenge = widget.challenge;
    final done = challenge.isDone;
    final failed = challenge.isFailed;

    if (done) return Text(_i18n.doneAt(_commonI18n.formatDate(challenge.doneAt)));
    else if (failed) {
      return Text(_i18n.failedSince(_commonI18n.formatDate(challenge.latestAt)), style: _overDueStyle);
    } else if (challenge.isOverdue) {
      if (challenge.latestAt == null) {
        return Text('Was due ' + _commonI18n.formatDate(challenge.dueAt), style: _overDueStyle);
      } else {
        return Text(_i18n.challengeWillFail(challenge.latestDiff(DateTime.now())), style: _overDueStyle);
      }
    } else {
      return Text(_i18n.dueUntil(_commonI18n.formatDate(challenge.dueAt)));
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(_challengeService != null);

    final challenge = widget.challenge;
    final done = challenge.isDone;
    final failed = challenge.isFailed;
    final theme = Theme.of(context);
    _attached ??= _challengeService.attach(challenge);
    assert(_attached != null);

    var actions = <Widget>[];
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
      actionPane: SlidableDrawerActionPane(),
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
          onLongPress: (challenge.status == ChallengeStatus.open ? _onEditChallenge : null),
          trailing: SizedBox(
            height: 64,
            child: Checkbox(
              value: done,
              onChanged: (v) => _onChallengeChecked(v, context),
            ),
          ),
        ),
      ),
      secondaryActions: actions
    );
  }
}
